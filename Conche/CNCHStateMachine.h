//
//  CNCHStateMachine.h
//  Conche
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT  NSString * __nonnull const CNCHStateMachineSuspendedNotification;
FOUNDATION_EXPORT NSString * __nonnull const CNCHStateMachineInvalidatedNotification;

@class CNCHStateMachine;

@protocol CNCHState <NSObject>

- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void(^)(__nullable id<CNCHState> state))completionHandler;

@end

@interface CNCHStateMachine : NSObject

- (nullable instancetype)initWithState:(nonnull id<CNCHState>)state;

- (void)resume;
- (void)suspend;
- (void)invalidate;

- (void)flushWithCompletionHandler:(nonnull void(^)(void))completionHandler;

@property (nullable, readonly) id<CNCHState> state;

@end
