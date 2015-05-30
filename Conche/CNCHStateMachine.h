//
//  CNCHStateMachine.h
//  Conche
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const CNCHStateMachineSuspendedNotification;
FOUNDATION_EXPORT NSString * const CNCHStateMachineInvalidatedNotification;

@class CNCHStateMachine;

@protocol CNCHState <NSObject>

- (void)stateMachine:(CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(void(^)(id<CNCHState> state))completionHandler;

@end

@interface CNCHStateMachine : NSObject

- (void)resume;
- (void)suspend;
- (void)invalidate;

- (void)flushWithCompletionHandler:(void(^)(void))completionHandler;

@property (readonly) id<CNCHState> state;

@end
