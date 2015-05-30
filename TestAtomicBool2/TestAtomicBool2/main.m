//
//  main.m
//  TestAtomicBool2
//
//  Created by Dan Stenmark on 5/30/15.
//  Copyright (c) 2015 Dan Stenmark. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		BOOL test = NO;
		NSLog(@"%d", OSAtomicTestAndSetBarrier(sizeof(test) * 8 - 3, &test));
		NSLog(@"%d", OSAtomicTestAndSetBarrier(sizeof(test) * 8 - 3, &test));
		NSLog(@"%d", OSAtomicTestAndSetBarrier(sizeof(test) * 8 - 3, &test));
		
		NSLog(@"%d", test);
	}
    return 0;
}
