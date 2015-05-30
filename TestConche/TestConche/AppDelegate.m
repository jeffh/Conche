//
//  AppDelegate.m
//  TestConche
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//

#import "AppDelegate.h"
#import <Conche/Conche.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end


@interface Tick : NSObject <CNCHStateful>

@end

@interface Tock : NSObject <CNCHStateful>

@end

@implementation Tick

- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void (^)(id<CNCHStateful> __nullable))completionHandler {
	NSLog(@"Tick");
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		completionHandler( [[Tock alloc] init] );
	});
}

@end

@implementation Tock

- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void (^)(id<CNCHStateful> __nullable))completionHandler {
	NSLog(@"Tock");
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		completionHandler( [[Tick alloc] init] );
	});
}

@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	CNCHStateMachine *stateMachine = [[CNCHStateMachine alloc] initWithState:[[Tick alloc] init]];
	[stateMachine resume];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[stateMachine invalidate];
		[stateMachine flushWithCompletionHandler:^{
			NSLog(@"Done");
		}];
	});
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
