//
//  main.m
//  igeostart
//
//  Created by Tom on 09-10-16.
//  Copyright Simon Fraser University 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"igeostartAppDelegate");
	[pool release];
	return retVal;
}
