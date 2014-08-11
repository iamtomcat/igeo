//
// gameModule.h
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
// Version 3.0
//   Edited by Nawin Khaikaew
//   Changes:
//   - adapt to new Explore module
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

// gameModule
@interface gameAsiaOceania : Layer
{
	//Database Variables
	PLSqliteDatabase *db;
	NSString *databaseName;
	NSString *databasePath;
	NSFileManager *fileManager;
	NSString *query;// current query that will be used
	id<PLResultSet> querySet; //
	UITextField *myText;
	NSString *playerName;
	
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
	
	//Game Variables
	int answerID[10]; //the tileID of the correct country
	NSString *countryName;
	NSMutableArray *myMutableArray;
	int right;// Counter
	int wrong;//    "
	int stage;// stage level
	int continent;// continent played (0=whole world)
	int questionCount;// number of question asked in current level
	int numQuestionCount[50];//random number storage
	
}

// returns a Scene that contains Explore as the only child
+(id) scene;

@end

