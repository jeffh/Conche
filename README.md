# Conche
Conche is a lightweight framework for implementing state machines in Objective-C.  It is designed with the following goals in mind:

- High scalability via non-blocking design.
- Precise control of the state machine class via its `resume`, `suspend`, and `invalidate` methods.
- Flexibility through subclassing.

# Example (Tick-Tock)

Below is an example of Conche being used in an application that prints out text every second, alternating between `Tick` and `Tock`.  After ten seconds, it invalidates and flushes the state machine.

## Code
```
@interface Tick : NSObject <CNCHStateful>

@end

@interface Tock : NSObject <CNCHStateful>

@end


@implementation Tick

- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void (^)(id<CNCHStateful> __nullable))completionHandler {

	// Print out Tick
	NSLog(@"Tick");
	
	// Sleep for a second before enqueueing the next state
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		completionHandler( [[Tock alloc] init] );
	});
}

@end

@implementation Tock

- (void)stateMachine:(nonnull CNCHStateMachine *)stateMachine transitionWithCompletionHandler:(nonnull void (^)(id<CNCHStateful> __nullable))completionHandler {
	
	// Alternatively, we can suspend the state machine for a second instead.
	// This is useful when you want to apply limits to how many times you
	// can process a state per second.
	
	[stateMachine suspend];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[stateMachine resume];
	});
	
	// Print out Tock
	NSLog(@"Tock");
	
	// Enqueue the next state
	completionHandler( [[Tick alloc] init] );
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

@end
```

## Output

```
2015-05-30 14:29:03.700 TickTock[48334:38612702] Tick
2015-05-30 14:29:04.700 TickTock[48334:38612724] Tock
2015-05-30 14:29:05.780 TickTock[48334:38612724] Tick
2015-05-30 14:29:06.780 TickTock[48334:38612724] Tock
2015-05-30 14:29:07.780 TickTock[48334:38612724] Tick
2015-05-30 14:29:08.797 TickTock[48334:38612724] Tock
2015-05-30 14:29:09.797 TickTock[48334:38612724] Tick
2015-05-30 14:29:10.874 TickTock[48334:38612724] Tock
2015-05-30 14:29:11.966 TickTock[48334:38612724] Tick
2015-05-30 14:29:13.045 TickTock[48334:38612724] Tock
2015-05-30 14:29:14.130 TickTock[48334:38612780] Done

```
