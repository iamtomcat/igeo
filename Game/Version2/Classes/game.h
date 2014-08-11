//
// Game.h
// iGeo
//
// Team iGeo
//
// Created by Tom Clark 09-11-09
//
// Version 1.0
//   Not created yet
//
// Version 2.0
//   Edited by Tom Clark
//   Changes:
//   - Creation
// 
// List of Known Bugs:
//   - Not yet found
//
// Dependencies:
//   - cocos2d framework
//	 - sqlite3 framework
//
// Last edtied by Nawin Khaikaew
//   Date: Nov 17, 2009
//   Time: 3:05 PM
//
// Copyright Simon Fraser University 2009, All right reserved.
//

#import "cocos2d.h"
#import <PlausibleDatabase/PlausibleDatabase.h>
#import <sqlite3.h>

// Explore Layer
@interface Game : Layer
{
	//Database Variables
	PLSqliteDatabase *db;
	NSString *databaseName;
	NSString *databasePath;
	NSFileManager *fileManager;
	
	//Map Variables
	CGPoint currentPos;//current map postion
	CGSize mapLayerSize;
	int heightPixels;//height of the map in pixels
	int widthPixels;//width of the map in pixels
	float zoomFactor;
	
	//Game Variables
	int clicks;
	int randomNum;
	bool questionAns;//has question been answer
	int right;// Counter
	int wrong;//    "
}

// returns a Scene that contains Explore as the only child
+(id) scene;

@end
