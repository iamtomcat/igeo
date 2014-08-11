//
// mainMenuScene.h
// iGeo
//
// Team iGeo
//
// Created by Tom Clark 05-10-09
//
// Version 1.0
//   Edited by Tom Clark
//   Changes:
//   - Creation
// 
// List of Known Bugs:
//
// Dependencies:
//   - cocos2d framework
//
// Last edtied by Alex Bumbac
//   Date: Nov 05, 2009
//   Time: 3:30 PM
//
// Copyright Simon Fraser University 2009, All right reserved.
//

#import "cocos2d.h"

// mainMenuScene Layer

@interface howTo : Layer
{
	CGPoint currentPos;
	int pageNumber;
	int pageTag[5];
}

// returns a Scene that contains the mainMenuScene as the only child
+(id) scene;

@end

