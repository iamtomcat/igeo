//
// Explore.h
// iGeo
//
// Team iGeo
//
// Created by Tom Clark 09-10-16
//
// Version 1.0
//   Edited by Tom Clark
//   Changes:
//   - Creation
//   - Integrated database
// 
// List of Known Bugs:
//   - None
//
// Dependencies:
//   - cocos2d framework
//	 - sqlite3 framework
//
// Last edtied by Alex Bumbac
//   Date: Nov 05, 2009
//   Time: 3:05 PM
//
// Copyright Simon Fraser University 2009, All right reserved.
//

#import "cocos2d.h"
#import <PlausibleDatabase/PlausibleDatabase.h>
#import <sqlite3.h>

// Explore Layer
@interface Explore : Layer
{
	CGPoint currentPos;
	PLSqliteDatabase *db;
	NSString *databaseName;
	NSString *databasePath;
	NSFileManager *fileManager;
	CGSize mapLayerSize;
	int heightPixels;
	int widthPixels;
	float zoomFactor;
}

// returns a Scene that contains Explore as the only child
+(id) scene;

@end
