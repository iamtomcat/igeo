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
// Version 2.0
//   Edited by Tom Clark
//   Changes:
//   - Adding zoom factor
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
@interface Explore : CCLayer
{
	//Database Variables
	PLSqliteDatabase *db;
	NSString *databaseName;
	NSString *databasePath;
	NSFileManager *fileManager;
	
	//Map Variables
	CGPoint currentPos;
	CGSize mapLayerSize;
	int heightPixels;
	int widthPixels;
	float zoomFactor;
	int positionTag [22][10];
	bool emptyTile [22][10];
	bool isLoaded[22][10];
	int saveCurrentx;
	int saveCurrenty;
	int z;
}

// returns a Scene that contains Explore as the only child
+(id) scene;

@end
