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
	
	NSString *string2;
	
	if (tapCount == 2) {
		CGPoint touchLocation = [touch locationInView: [touch view]];	
		CGPoint convertedPoint = [[Director sharedDirector] convertToGL:touchLocation];
		
		id map = [self getChildByTag:kTagTileMap];
		TMXLayer *namepop = [map layerNamed:@"tile_id"];

		CGPoint addtest = ccpSub(convertedPoint, currentPos);
		
		unsigned int test = [namepop tileGIDAt:ccp((int)(addtest.x / 20),(50 - (int)addtest.y / 20))];
		
		
		if (test==0)
		{
				
		}
		else
		{
			NSNumber *inputInt = [[NSNumber alloc] initWithInteger: test];
			string2 = [self getCountryName:inputInt];
		}

		//Test Strings
		//NSString *string1 = [NSString stringWithFormat:@"x: %d,y:%d",(int)addtest.x/20,50-(int)addtest.y/20];//(int)currentPos.y/32,(int)currentPos.x/32];//(int)(64-(convertedPoint.x/32)),(int)(convertedPoint.y/32)];
		//NSString *string2 = [NSString stringWithFormat:@"Gid: %d",test];			
		//NSString *string1 = [NSString stringWithFormat:@"Gid: %d",(int)currentPos.y];		

		//updates label with country name whecn clicked
		Label *label = (Label*) [self getChildByTag:kTagBitmapAtlas3];
		[label setString:string2];
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
-(void) checkPos:(ccTime)dt
{	
	CocosNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	
	//Check for bottom left corner
	if ((currentPos.x>8)&&(currentPos.y>8)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(0, 0)]];
	}
	//check for top left corner
	else if ((currentPos.x>8)&&(currentPos.y<-708)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(0, -700)]];
	}
	//check for bottom right corner
	else if ((currentPos.x<-548)&&(currentPos.y>8)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-540, 0)]];
	}
	//check for top right corner
	else if ((currentPos.x<-548)&&(currentPos.y<-708)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-540, -700)]];
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
	else if(((int)currentPos.y)<-708)
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(currentPos.x, -700)]];		
	}
	//right check to make sure user can't go too far right
	else if(((int)currentPos.x)<-548)
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-540, currentPos.y)]];
	}
	else
	{
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
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"europe_version_1.tmx"];
		map.position = ccp(-400,-400);
		[self addChild:map z:0 tag:kTagTileMap];
		
		//database code below
		databaseName = @"worldMap.db";
		
		// Get the path to the documents directory and append the databaseName
		NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [Paths objectAtIndex:0];
		databasePath = [documentsDir stringByAppendingFormat:databaseName];
		
		// Execute the "checkAndCreateDatabase" function
		[self checkAndCreateDatabase];
		// initialize db
		db = [[PLSqliteDatabase alloc] initWithPath: databasePath];

		// check if it can open
		if(![db open])
			[label setString:@"Could not open database"]; //replace this with the error msg
		
		//calls a scheduler to check boundaries
		[self schedule:@selector(checkPos:) interval:0.2f];
	}
	return self;
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
	id<PLResultSet> results = [db executeQuery: @"SELECT * FROM worldMap WHERE tileId = ?", tileID];
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