//
//  CNCHStateMachine.m
//  Conche
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//
//	This software may be modified and distributed under the terms
//	of the MIT license.  See the LICENSE file for details.

#import "CNCHStateMachine.h"

NSString * const CNCHStateMachineSuspendedNotification = @"CNCHStateMachineSuspendedNotification";
NSString * const CNCHStateMachineInvalidatedNotification = @"CNCHStateMachineInvalidatedNotification";

@implementation CNCHStateMachine {
	id<CNCHStateful> _state;
	
	dispatch_queue_t __queue;
	dispatch_source_t __source;
	dispatch_group_t __group;
	
	OSSpinLock __stateSpinLock;
}

- (instancetype)initWithState:(id<CNCHStateful>)state {
	
	if( state == nil ) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"state cannot be nil" userInfo:nil];
	}
	
	self = [super init];
	if( self != nil ) {
		_state = state;
		
		__stateSpinLock = OS_SPINLOCK_INIT;
		
		__queue = dispatch_queue_create( NULL, DISPATCH_QUEUE_SERIAL );
		__group = dispatch_group_create();
		__source = dispatch_source_create( DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, __queue );
		
		dispatch_source_set_registration_handler( __source, ^{
			dispatch_source_merge_data( __source, 1 );
		});
		
		dispatch_source_set_event_handler( __source, ^{
			
			dispatch_suspend( __source );
			
			dispatch_group_enter( __group );
			
			__block volatile int32_t completionHandlerInvocations = 0;
			[self.state stateMachine:self transitionWithCompletionHandler:^(__nullable id<CNCHStateful> state) {
				if( (completionHandlerInvocations = OSAtomicIncrement32( &completionHandlerInvocations )) > 1 ) {
					@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"competion handler cannot be called more than once" userInfo:nil];
				}
				
				[self willChangeValueForKey:NSStringFromSelector(@selector(state))];
				
				OSSpinLockLock( &__stateSpinLock );
				_state = state;
				OSSpinLockUnlock( &__stateSpinLock );
				
				[self didChangeValueForKey:NSStringFromSelector(@selector(state))];
				
				if( _state != nil ) {
					dispatch_source_merge_data( __source, 1 );
				}
				
				dispatch_group_leave( __group );
				dispatch_resume( __source );
			}];
		});
		
		dispatch_source_set_cancel_handler( __source, ^{
			dispatch_group_leave( __group );
		});
	}
	
	return self;
}

- (void)resume {
	dispatch_resume( __source );
}

- (void)suspend {
	dispatch_suspend( __source );
	
	dispatch_async( __queue, ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:CNCHStateMachineSuspendedNotification object:self];
	});
}

- (void)invalidate {
	dispatch_group_enter( __group );
	dispatch_source_cancel( __source );
	
	dispatch_async( __queue, ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:CNCHStateMachineInvalidatedNotification object:self];
	});
}

- (void)flushWithCompletionHandler:(void (^)(void))completionHandler {
	
	if( completionHandler == nil ) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"completionHandler cannot be nil" userInfo:nil];
	}
	
	dispatch_group_notify( __group, __queue, completionHandler );
}

- (id<CNCHStateful>)state {
	
	id<CNCHStateful> state = nil;
	OSSpinLockLock( &__stateSpinLock );
	state = _state;
	OSSpinLockUnlock( &__stateSpinLock );
	
	return state;
}

@end
