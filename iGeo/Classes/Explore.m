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
// Version 2.0
//   Edited by Tom Clark
//   Changes:
//   - Change database signature to .sql
//   - Implement zoom function
// 
// List of Known Bugs:
//   - when using the iPhone simulator, if dragging with two
//     fingers on the trackpad to move around, the
//     ccTouchEnded function lags, and needs a bit of time
//     start working again
//   - the top of the map 'seems' cut off, but we chose to
//     just implement that much of the map for version 2
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
#import "mainMenuScene.h"


enum {
	kTagTileMap = 1,
	kTagBitmapAtlas3 = 2,
	quitMenuTag = 3,
	quitPromptTag = 4,
};

// Explore implementation
@implementation Explore

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Explore *layer = [Explore node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
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

//touch recognition function
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:touchLocation];
		
		id map = [self getChildByTag:kTagTileMap];
		//TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"worldMap.tmx"];
		CCTMXLayer *namepop = [map layerNamed:@"tileId"];

		CGPoint addtest = ccpSub(convertedPoint, currentPos);
		
		unsigned int test = [namepop tileGIDAt:ccp((int)(addtest.x / (int)(32*zoomFactor)),((mapLayerSize.height-1) - (int)addtest.y / (int)(32*zoomFactor)))];
		
		
		if (test==0)
		{
				
		}
		else
		{
			NSNumber *inputInt = [[NSNumber alloc] initWithInteger: test];
			output = [self getCountryName:inputInt];
			CCLabelAtlas *label = (CCLabelAtlas*) [self getChildByTag:kTagBitmapAtlas3];
			[label setString:output];
		}
		//updates label with country name whecn clicked
		
	}
}

//function that allows you to move around the map
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);

	
	CCNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	CGPoint holdPos = currentPos;//[node position];

	currentPos = ccpAdd(holdPos,diff);
	[node setPosition: currentPos];

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


//current position timer to make sure that you don't go out of bounds
-(void) checkBounds:(ccTime)dt
{	
	CCNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	
	heightPixels = (((mapLayerSize.height*(32*zoomFactor))-320)+8);
	widthPixels =	(((mapLayerSize.width*(32*zoomFactor))-480)+8);
	
	//Check for bottom left corner
	if ((currentPos.x>8)&&(currentPos.y>8)) 
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(0, 0)]];
	}
	//check for top left corner
	else if ((currentPos.x>8)&&(currentPos.y<-heightPixels)) 
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(0, -(heightPixels-8))]];
	}
	//check for bottom right corner
	else if ((currentPos.x<-widthPixels)&&((currentPos.y*zoomFactor)>(8*zoomFactor))) 
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), 0)]];
	}
	//check for top right corner
	else if ((currentPos.x<-widthPixels)&&(currentPos.y<-heightPixels)) 
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), -(heightPixels-8))]];
	}
	//Left Side Check to make sure the user can't go any farther left
	else if (currentPos.x>8) 
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(0, currentPos.y)]];
	}
	//bottem check to make sure user can't go down too far
	else if(currentPos.y>8)
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(currentPos.x, 0)]];
	}
	//top check to make sure user can't go too far up
	else if(((int)currentPos.y)<-(heightPixels))
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp((currentPos.x), -(heightPixels-8))]];		
	}
	//right check to make sure user can't go too far right
	else if(((int)currentPos.x)<-widthPixels)
	{
		[node runAction:[CCMoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), (currentPos.y))]];
	}

	
}

//loads a grid of 3x3 tileMaps centered around current position
-(void)loadMapGrid : (int) xCoord: (int) yCoord	
{
	id map = [self getChildByTag:kTagTileMap];
	//int yCoord = (int)-((currentPos.y-160)/(512*zoomFactor));
	//int xCoord = (int)-((currentPos.x-240)/(512*zoomFactor));
	
	if(xCoord==0)
	{
		//bottom left corner
		if(yCoord==0)
		{
			for (int x=0; x<2; x++)
			{
				for (int y=0; y<2; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
		
		//top left corner
		else if(yCoord==21)
		{
			for (int x=0; x<2; x++)
			{
				for (int y=-1; y<1; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
		
		//left margin
		else
		{
			for (int x=0; x<2; x++)
			{
				for (int y=-1; y<2; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
	}
	
	else if(xCoord==21)
	{
		//bottom right corner
		if(yCoord==0)
		{
			for (int x=-1; x<1; x++)
			{
				for (int y=0; y<2; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
		
		//top right corner
		if(yCoord==0)
		{
			for (int x=-1; x<1; x++)
			{
				for (int y=-1; y<1; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
		
		//right margin
		else
		{
			for (int x=-1; x<1; x++)
			{
				for (int y=-1; y<2; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
						nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
						
						[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
						isLoaded[xCoord+x][yCoord+y]=TRUE;
					}
					
					else
					{
						
					}
				}
			}
		}
	}
	
	//bottom margin
	else if(yCoord==0)
	{
		for (int x=-1; x<1; x++)
		{
			for (int y=0; y<2; y++)
			{
				if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
				{
					NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
					CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
					nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
					
					[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
					isLoaded[xCoord+x][yCoord+y]=TRUE;
				}
				
				else
				{
					
				}
			}
		}
	}
	
	//top margin
	else if(yCoord==10)
	{
		for (int x=-1; x<1; x++)
		{
			for (int y=-1; y<1; y++)
			{
				if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
				{
					NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
					CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
					nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
					
					[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
					isLoaded[xCoord+x][yCoord+y]=TRUE;
				}
				
				else
				{
					
				}
			}
		}
	}
	
	//rest of the map
	else
	{
		for (int x=-1; x<2; x++)
		{
			for (int y=-1; y<2; y++)
			{
				if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
				{
					NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
					CCTMXTiledMap *nextTile = [CCTMXTiledMap tiledMapWithTMXFile:nextTileString];
					nextTile.position = ccp(((xCoord+x)*512),((yCoord+y)*512));
					
					[map addChild:nextTile z:0 tag:positionTag[xCoord+x][yCoord+y]];
					isLoaded[xCoord+x][yCoord+y]=TRUE;
				}
				
				else
				{
					
				}
			}
		}
		
	}
}


//Turns on and off the tiles based on position
-(void) checkMapPos:(ccTime) dt
{
	int yCoord = (int)-((currentPos.y-160)/(512*zoomFactor));
	int xCoord = (int)-((currentPos.x-240)/(512*zoomFactor));


	
	/*
	 NSString *string1 = [NSString stringWithFormat:@"X:%d,Y:%d",xCoord,yCoord];		
	Label *label = (Label*) [self getChildByTag:kTagBitmapAtlas3];
	[label setString:string1];
	 */
	
	if(xCoord<0 || yCoord<0 || xCoord>21 || yCoord>10 || (xCoord==0 && yCoord==0))
	{
	
	}
	
	//initializing
	else if((isLoaded[xCoord][yCoord]==FALSE))
	{
		[self loadMapGrid: xCoord: yCoord];
		
		saveCurrentx = xCoord;
		saveCurrenty = yCoord;
	}
	
	//moving right
	else if((isLoaded[xCoord][yCoord]==TRUE) && (xCoord>saveCurrentx && yCoord==saveCurrenty))
	{
		id map = [self getChildByTag:kTagTileMap];
		
		//remove a column at x-2 + y,y+1,y-1
		for (int y=-1; y<2; y++)
		{
			if (isLoaded[xCoord-2][yCoord+y]==TRUE)
			{
				id test2 = [map getChildByTag:positionTag[xCoord-2][yCoord+y]];
				[map removeChild:test2 cleanup:YES];
				isLoaded[xCoord-2][yCoord+y]=FALSE;
			}
			
			else
			{
				
			}
		}
		
		[self loadMapGrid: xCoord: yCoord];		
		saveCurrentx = xCoord;
		saveCurrenty = yCoord;
	}
	
	//moving left
	else if((isLoaded[xCoord][yCoord]==TRUE) && (xCoord<saveCurrentx && yCoord==saveCurrenty))
	{
		id map = [self getChildByTag:kTagTileMap];
		
		//remove a column at x+2 + y,y+1,y-1
		for (int y=-1; y<2; y++)
		{
			if (isLoaded[xCoord+2][yCoord+y]==TRUE)
			{
				id test2 = [map getChildByTag:positionTag[xCoord+2][yCoord+y]];
				[map removeChild:test2 cleanup:YES];
				isLoaded[xCoord+2][yCoord+y]=FALSE;
			}
			
			else
			{
				
			}
		}
		
		[self loadMapGrid: xCoord: yCoord];		
		saveCurrentx = xCoord;
		saveCurrenty = yCoord;
	}
	
	//moving up
	else if((isLoaded[xCoord][yCoord]==TRUE) && (xCoord==saveCurrentx && yCoord>saveCurrenty))
	{
		id map = [self getChildByTag:kTagTileMap];
		
		//remove a row at y-2 + x,x+1,x-1
		for (int x=-1; x<2; x++)
		{
			if (isLoaded[xCoord+x][yCoord-2]==TRUE)
			{
				id test2 = [map getChildByTag:positionTag[xCoord+x][yCoord-2]];
				[map removeChild:test2 cleanup:YES];
				isLoaded[xCoord+x][yCoord-2]=FALSE;
			}
			
			else
			{
				
			}
		}
		
		[self loadMapGrid: xCoord: yCoord];		
		saveCurrentx = xCoord;
		saveCurrenty = yCoord;
	}
	
	//moving down
	else if((isLoaded[xCoord][yCoord]==TRUE) && (xCoord==saveCurrentx && yCoord<saveCurrenty))
	{
		id map = [self getChildByTag:kTagTileMap];
		
		//remove a row at y+2 + x,x+1,x-1
		for (int x=-1; x<2; x++)
		{
			if (isLoaded[xCoord+x][yCoord+2]==TRUE)
			{
				id test2 = [map getChildByTag:positionTag[xCoord+x][yCoord+2]];
				[map removeChild:test2 cleanup:YES];
				isLoaded[xCoord+x][yCoord+2]=FALSE;
			}
			
			else
			{
				
			}
		}
		
		[self loadMapGrid: xCoord: yCoord];		
		saveCurrentx = xCoord;
		saveCurrenty = yCoord;
	}
}	

-(void)loadMaps
{
	z=3;
	saveCurrentx = 0;
	saveCurrenty = 0;
	
	for (int y=0; y<11; y++) 
	{
		for (int x=0; x<22; x++)
		{
			positionTag[x][y]=z;
			isLoaded[x][y]=FALSE;
			z++;
		}
	}
	
	//loads tile map into the scene
	CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"worldMap.tmx"];
	map.position = ccp(-5000,-3500);
	[self addChild:map z:0 tag:kTagTileMap];
	
	//Sets the size of layer
	CCTMXLayer *mapLayer = [map layerNamed:@"tileId"];
	mapLayerSize = [mapLayer layerSize];
	mapLayer.visible = NO;
	
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{
		/*int emptyList[124] = {0,1,2,3,4,7,8,9,10,11,
							12,13,14,15,16,17,18,19,20,21,50,//row 0
							0,1,2,3,4,7,8,9,10,11,
							12,13,14,15,16,50,//row 1
							0,1,2,3,4,8,9,13,14,15,
							16,50,//row 2
							0,1,2,3,4,8,9,13,14,15,50,//row 3
							0,1,2,3,21,50,//row 4
							0,1,2,7,19,20,21,50,//row 5
							0,1,7,8,9,19,20,21,50,//row 6
							7,8,20,21,50,//row 7
							7,8,20,21,50,//row 8
							7,8,9,10,11,20,21,50,//row 9
							0,1,6,7,8,9,10,11,12,13,50,
							14,15,16,17,18,19,20,21};//row 10
							
		
		int y=0;
		for (int x=0; x<125; x++)
		{
			
			int hold = emptyList[x];
			if (hold==50) 
			{
				y++;
			}
			else 
			{
				emptyTile[hold][y]=TRUE;
			}
		}*/
		
		
		//Enables touch
		self.isTouchEnabled = YES;
		
		zoomFactor = 1;
		
		//retrieves size of the window.
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		//set background
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
		CCSprite *labelBackground = [CCSprite spriteWithFile:@"exploreLabel.png"];
		[self addChild:labelBackground z:1];
		labelBackground.position = ccp(s.width/2,s.height-25);
		//Creates a Blank Label to be updated later
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"tap a country" fontName:@"comic_andy" fontSize:40];
		//set font colour
		[label setColor:ccc3(0, 0, 0)];
		//sets the label position
		label.position = ccp(s.width/2,s.height-20);
		//Adds label to scene
		[self addChild:label z:2 tag:kTagBitmapAtlas3];

		[self loadMaps];
		
		CCMenuItemImage *zoomin = [CCMenuItemImage itemFromNormalImage:@"zoomin.png" selectedImage:@"zoominClicked.png"  target:self selector:@selector(zoomIn:)];
		CCMenuItemImage *zoomout = [CCMenuItemImage itemFromNormalImage:@"zoomout.png" selectedImage:@"zoomoutClicked.png"  target:self selector:@selector(zoomOut:)];
		CCMenuItemImage *quit = [CCMenuItemImage	itemFromNormalImage:@"quit.png" selectedImage:@"quitClicked.png" target:self selector:@selector(quitButton:)];

		CCMenu *menu = [CCMenu menuWithItems:quit, zoomout, zoomin, nil];
				
		menu.position = CGPointZero;
		
		zoomout.position = ccp(s.width/2 - 180,30);
		zoomin.position = ccp(s.width/2 + 180,30);
		quit.position = ccp(s.width/2 - 217,30);
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
		[self schedule:@selector(checkMapPos:) interval:0.1f];
	}
	return self;
}

// There are 4 zooming sizes:
//   2.0, 1.5, 1.0, 0.5 where
//   - 2.0: max zoom in
//   - 0.5: max zoom out
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
		CCNode *node = [self getChildByTag:kTagTileMap];
		currentPos = [node position];
		CGPoint savepos = currentPos;
		
		[node runAction:[CCMoveTo actionWithDuration:0.2f position:ccp((int)((savepos.x*multiply)+120),(int)((savepos.y*multiply)+80))]];
		[node runAction:[CCScaleTo actionWithDuration:0.2f scale:zoomFactor]];
		[self schedule:@selector(checkBounds:) interval:0.2f];
	}
	
}

-(void)zoomIn: (id) sender
{
	float multiply = 0;
	bool run=TRUE;
	if(zoomFactor==0.10)
	{
		zoomFactor = 0.25;
		multiply = 2.5;
	}
	else if(zoomFactor==0.25)
	{
		zoomFactor = 0.5;
		multiply = 2;
	}
	else if (zoomFactor==0.5) 
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

//function what to do when click yes
- (void)quit: (id) sender
{
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}

//function what to do when click no
- (void)noQuit: (id) sender
{
	CocosNode *rem1 = [self getChildByTag:quitMenuTag];
	CocosNode *rem2 = [self getChildByTag:quitPromptTag];
	[self removeChild: rem1 cleanup: YES];
	[self removeChild: rem2 cleanup: YES];
}

//function, when click x
- (void)quitButton: (id) sender
{
	Sprite *quitPrompt = [Sprite spriteWithFile:@"quitPrompt.png"];
	[self addChild:quitPrompt z:1 tag:quitPromptTag];
	quitPrompt.position = ccp(480/2,320-160);
	
	MenuItemImage *yes = [MenuItemImage itemFromNormalImage:@"yes.png" selectedImage:@"yesClicked.png"  target:self selector:@selector(quit:)];
	MenuItemImage *no = [MenuItemImage itemFromNormalImage:@"no.png" selectedImage:@"noClicked.png"  target:self selector:@selector(noQuit:)];
	
	Menu *quitMenu = [Menu menuWithItems:yes, no, nil];
	
	quitMenu.position = CGPointZero;
	yes.position = ccp(480/2 - 51,320-190);
	no.position = ccp(480/2 + 51,320-190);
	
	[self addChild: quitMenu z:2 tag:quitMenuTag];

}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	[fileManager removeItemAtPath: databasePath error:NULL];
	[super dealloc];
}
@end