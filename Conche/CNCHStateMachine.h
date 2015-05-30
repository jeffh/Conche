//
//  CNCHStateMachine.h
//  Conche
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//
//	This software may be modified and distributed under the terms
//	of the MIT license.  See the LICENSE file for details.

#import <Foundation/Foundation.h>

/*!
 This notification is posted on the \c CNCHStateMachine object's private serial queue
 when @c[CNCHStateMachine suspend]; is called.
 */
FOUNDATION_EXPORT NSString * __nonnull const CNCHStateMachineSuspendedNotification;

/*!
 This notification is posted on the \c CNCHStateMachine object's private serial queue
 upon the object getting invalidated via @c[CNCHStateMachine invalidate];.
 */
FOUNDATION_EXPORT NSString * __nonnull const CNCHStateMachineInvalidatedNotification;

@class CNCHStateMachine;



@protocol CNCHStateful <NSObject>

/*!
 @brief The method that is invoked by the state machine to process and the current state and
 transition to the next one.
 
 @discussion When running as part of a state machine, this method will always be invoked on
 the state machine's private serial queue.
 
 @param stateMachine The state machine that this method is currently being invoked from.
 
 @param completionHandler The completion hander where the resulting state should be passed into.
 If it is invoked more than once, the state machine will throw an \c NSInternalInconsistencyException.
 */
- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void(^)(__nullable id<CNCHStateful> state))completionHandler;

@end



@interface CNCHStateMachine : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;

/*!
 @brief Returns a new \c CNCHStateMachine object with its initial state set to \c state.
 
 @discussion The newly created \c CNCHStateMachine object is returned in a suspended state.  
 Call \c resume to have it begin processing states.
 
 @param  state The initial state of the \c CNCHStateMachine object.
 
 @return A new \c CNCHStateMachine object with its initial state set to \c state.
 */
- (nullable instancetype)initWithState:(nonnull id<CNCHStateful>)state NS_DESIGNATED_INITIALIZER;


/*!
 @brief Starts or resumes the state machine.
 
 @discussion All state machines start suspended.  You must resume them before they can
 begin processing states.
 
 */
- (void)resume;


/*!
 @brief Suspends the state machine.
 
 @discussion Suspends and resumes must be balanced before the connection may be invalidated.  
 Posts \c CNCHStateMachineSuspendedNotification.
 
 */
- (void)suspend;


/*!
 @brief Invalidates the state machine.
 
 @discussion The state machine must be invalidated before it can be deallocated.
 After a state machine is invalidated, no further states will be processed.  Upon
 invalidation, \c CNCHStateMachineInvalidatedNotification will be posted.
 
 */
- (void)invalidate;


/*!
 @brief Flushes the currently processing state and invokes the 
 specified completion handler.
 
 @discussion The specified completion handler will be invoked on the state machine's
 private serial queue.
 
 @param completionHandler The completion handler to be invoked when the currently
 processing state is flushed.
 
 */
- (void)flushWithCompletionHandler:(nonnull void(^)(void))completionHandler;


/*!
 The state machine's current state.  This property is observable via KVO.
 */
@property (nullable, readonly) id<CNCHStateful> state;

@end
