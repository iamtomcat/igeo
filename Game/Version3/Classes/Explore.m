//
// Explore.m
// iGeo
//
// Team iGeo
//
// Created by Tom Clark 09-10-16
//
// Version 1.0
//   Edited by Tom Clark, Nawin Khaikaew, Alex Bumbac
//   Changes:
//   - Creation
//   - Background and Labels
//   - Tile Map Implementation
//   - Clicking and Moving
//   - Returning tileId on click
//	 - Boundary Implemenation and Boundary Recognition
//   - Database Integration
//   - Return Country Name
//
// List of Known Bugs:
//   - when using the iPhone simulator, if dragging with two
//     fingers on the trackpad to move around, the
//     ccTouchEnded function lags, and needs a bit of time
//     start working again
//   - the top of the map 'seems' cut off, but we chose to
//     just implement that much of the map for version 1
//   - no back button implemented
//
// Dependencies:
//   - cocos2d framework
//	 - sqlite3 framework
//
// Last edtied by Alex Bumbac
//   Date: Nov 05, 2009
//   Time: 3:25 PM
//
// References Used
//	 - building upon cocos2d examples provided with the framework
//	 - iPhone SDK Tutorial: Reading data from a SQLite Database, sample code used from
//     http://dblog.com.au/iphone-development-tutorials/iphone-sdk-tutorial-reading-data-from-a-sqlite-database/
//   - pldatabase Basic SQL Programming Guide, sample code used from
//     http://pldatabase.google.code/svn/tags/pldatabase-1.2.1/docs/exec_sql.html
//     open source project, PlausibleDatabase
//     
//
// Copyright Simon Fraser University 2009, All right reserved.
//

// Import the interfaces
#import "Explore.h"
#import <UIKit/UIKit.h>


enum {
	kTagSprite = 1,
	kTagTileMap = 2,
	kTagBitmapAtlas3 = 4,
};

// Explore implementation
@implementation Explore

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	Explore *layer = [Explore node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//touch recognition function
-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

//touch begin function
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

//touch end function, includes the tileId check and double click functionality
//updates the label on the screen with a country name
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSInteger tapCount = [touch tapCount];
	NSString *output;
	
	if (tapCount == 2) {
		CGPoint touchLocation = [touch locationInView: [touch view]];	
		CGPoint convertedPoint = [[Director sharedDirector] convertToGL:touchLocation];
		
		id map = [self getChildByTag:kTagTileMap];
		TMXLayer *namepop = [map layerNamed:@"tileId"];

		CGPoint addtest = ccpSub(convertedPoint, currentPos);
		
		unsigned int test = [namepop tileGIDAt:ccp((int)(addtest.x / (int)(32*zoomFactor)),((mapLayerSize.height-1) - (int)addtest.y / (int)(32*zoomFactor)))];
		
		
		if (test==0)
		{
				
		}
		else
		{
			NSNumber *inputInt = [[NSNumber alloc] initWithInteger: test];
			output = [self getCountryName:inputInt];
			Label *label = (Label*) [self getChildByTag:kTagBitmapAtlas3];
			[label setString:output];
		}

		//min+random+((max+1)-min)
		//int rand = 5 + arc4random() % 6;
		
		//Test Strings
		//NSString *string1 = [NSString stringWithFormat:@"x: %d,y:%d",(int)addtest.x/(int)(20*zoomFactor),50-(int)addtest.y/(int)(20*zoomFactor)];//(int)currentPos.y/32,(int)currentPos.x/32];//(int)(64-(convertedPoint.x/32)),(int)(convertedPoint.y/32)];
		//output = [NSString stringWithFormat:@"Gid: %d",rand];			
		//NSString *string1 = [NSString stringWithFormat:@"Gid: %d",(int)currentPos.y];		

		//updates label with country name whecn clicked
		
		}
}

//function that allows you to move around the map
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[Director sharedDirector] convertToGL: touchLocation];
	prevLocation = [[Director sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);

	
	CocosNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	CGPoint holdPos = currentPos;//[node position];

	currentPos = ccpAdd(holdPos,diff);
	[node setPosition: currentPos];

}

//current position timer to make sure that you don't go out of bounds
-(void) checkBounds:(ccTime)dt
{	
	CocosNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	
	heightPixels = (((mapLayerSize.height*(32*zoomFactor))-320)+8);
	widthPixels =	(((mapLayerSize.width*(32*zoomFactor))-480)+8);
	
		//Check for bottom left corner
		if ((currentPos.x>8)&&(currentPos.y>8)) 
		{
				[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(0, 0)]];
		}
		//check for top left corner
		else if ((currentPos.x>8)&&(currentPos.y<-heightPixels)) 
		{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(0, -(heightPixels-8))]];
		}
		//check for bottom right corner
		else if ((currentPos.x<-widthPixels)&&((currentPos.y*zoomFactor)>(8*zoomFactor))) 
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), 0)]];
		}
		//check for top right corner
		else if ((currentPos.x<-widthPixels)&&(currentPos.y<-heightPixels)) 
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), -(heightPixels-8))]];
		}
		//Left Side Check to make sure the user can't go any farther left
		else if (currentPos.x>8) 
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(0, currentPos.y)]];
		}
		//bottem check to make sure user can't go down too far
		else if(currentPos.y>8)
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(currentPos.x, 0)]];
		}
		//top check to make sure user can't go too far up
		else if(((int)currentPos.y)<-(heightPixels))
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp((currentPos.x), -(heightPixels-8))]];		
		}
		//right check to make sure user can't go too far right
		else if(((int)currentPos.x)<-widthPixels)
		{
			[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), (currentPos.y))]];
		}
	
	
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		//Enables touch
		self.isTouchEnabled = YES;
		[UIApplication sharedApplication].idleTimerDisabled=YES;
		
		zoomFactor = 1;
		
		//retrieves size of the window.
		CGSize s = [[Director sharedDirector] winSize];
		
		//set background
		Sprite *background = [Sprite spriteWithFile:@"background.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
		//Creates a Blank Label to be updated later
		Label *label = [Label labelWithString:@"" fontName:@"comic_andy" fontSize:50];
		//set font colour
		[label setColor:ccc3(0, 0, 0)];
		//sets the label position
		label.position = ccp(s.width/2,s.height-25);
		//Adds label to scene
		[self addChild:label z:1 tag:kTagBitmapAtlas3];
		
		//loads tile map into the scene
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"worldMap.tmx"];
		[map setAnchorPoint:ccp(0,0)];
		map.position = ccp(-400,-400);
		[self addChild:map z:0 tag:kTagTileMap];
		
		TMXTiledMap *strip1 = [TMXTiledMap tiledMapWithTMXFile:@"stripOne.tmx"];
		strip1.position = ccp(0,0);
		[map addChild:strip1];
		
		TMXTiledMap *strip2 = [TMXTiledMap tiledMapWithTMXFile:@"stripTwo.tmx"];
		strip2.position = ccp(512,0);
		[map addChild:strip2];
		
		TMXTiledMap *strip3 = [TMXTiledMap tiledMapWithTMXFile:@"stripThree.tmx"];
		strip3.position = ccp(1024,32);
		[map addChild:strip3];
		
		TMXTiledMap *strip4 = [TMXTiledMap tiledMapWithTMXFile:@"stripFour.tmx"];
		strip4.position = ccp(1536,32);
		[map addChild:strip4];
		
		TMXTiledMap *strip5 = [TMXTiledMap tiledMapWithTMXFile:@"stripFive.tmx"];
		strip5.position = ccp(2048,32);
		[map addChild:strip5];
		
		//Sets the size of layer
		TMXLayer *mapLayer = [map layerNamed:@"tileId"];
		mapLayerSize = [mapLayer layerSize];
		mapLayer.visible=NO;		
		
		
		MenuItemImage *zoomout = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(zoomOut:)];
		MenuItemImage *zoomin = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png"  target:self selector:@selector(zoomIn:)];
		Menu *menu = [Menu menuWithItems:zoomout, zoomin, nil];
		
		menu.position = CGPointZero;
		zoomout.position = ccp( s.width/2 - 100,30);
		zoomin.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:2];	
		
		
		//database code below
		databaseName = @"worldMap.sqlite";
		
		// Get the path to the documents directory and append the databaseName
		NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [Paths objectAtIndex:0];
		//for phone use stringByAppedingPathComponent
		//for testing use stringByAppendingFormat
		databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		
		// initialize db
		db = [[PLSqliteDatabase alloc] initWithPath: databasePath];
		
		// Execute the "checkAndCreateDatabase" function
		[self checkAndCreateDatabase];

		// check if it can open
		if(![db open])
			[label setString:@"Could not open database"]; //replace this with the error msg
		
		//calls a scheduler to check boundaries
		[self schedule:@selector(checkBounds:) interval:0.2f];
	}
	return self;
}

-(void)zoomOut: (id) sender
{
	float multiply = 0;
	bool run=TRUE;
	if (zoomFactor==2.0) 
	{
		zoomFactor = 1.5;
		multiply = 1.5/2;
	}
	else if(zoomFactor==1.5)
	{
		zoomFactor = 1.0;
		multiply = 1/1.5;
	}
	else if(zoomFactor==1.0)
	{
		zoomFactor = 0.5;
		multiply = 0.5;
	}
	else 
	{
		run = FALSE;
	}

	if(run==TRUE)
	{
		[self unschedule:@selector(checkBounds:)];
		CocosNode *node = [self getChildByTag:kTagTileMap];
		currentPos = [node position];
		CGPoint savepos = currentPos;
		
		[node runAction:[MoveTo actionWithDuration:0.2f position:ccp((int)((savepos.x*multiply)+120),(int)((savepos.y*multiply)+80))]];
		[node runAction:[ScaleTo actionWithDuration:0.2f scale:zoomFactor]];
		[self schedule:@selector(checkBounds:) interval:0.2f];
	}
	

	
}

-(void)zoomIn: (id) sender
{
	float multiply = 0;
	bool run=TRUE;
	if (zoomFactor==0.5) 
	{
		zoomFactor = 1.0;
		multiply = 2;
	}
	else if(zoomFactor==1.0)
	{
		zoomFactor = 1.5;
		multiply = 1.5;
	}
	else if(zoomFactor==1.5)
	{
		zoomFactor = 2.0;
		multiply = 2/1.5;
	}
	else 
	{
		run = FALSE;
	}
	
	if (run==TRUE) 
	{
		[self unschedule:@selector(checkBounds:)];
		CocosNode *node = [self getChildByTag:kTagTileMap];
		currentPos = [node position];
		CGPoint savepos = currentPos;
		//[node setPosition:ccp((savepos.x*zoomFactor),(savepos.y*zoomFactor))];
		[node runAction:[MoveTo actionWithDuration:0.2f position:ccp((int)((savepos.x*multiply)-120),(int)((savepos.y*multiply)-80))]];
		[node runAction:[ScaleTo actionWithDuration:0.2f scale:zoomFactor]];
		[self schedule:@selector(checkBounds:) interval:0.2f];
	}
	
}

//check and create database
-(void) checkAndCreateDatabase{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
}


//finds id in database and returns name of country.
- (NSString *)getCountryName: (NSNumber *)tileID{
	NSString *countryName;
	id<PLResultSet> results = [db executeQuery: @"SELECT * FROM worldMap WHERE Id = ?", tileID];
	while ([results next]) {
		countryName = [results stringForColumn: @"countryName"];
		
	}
	
	[results close];
	return countryName;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[fileManager removeItemAtPath: databasePath error:NULL];
	[super dealloc];
}
@end