//
// gameModule.m
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
//   Edited by Tom Clark, Nawin Khaikaew, Alex Bumbac
//   Changes:
//   - Creation: using the same logic as the Explore module
//   - Adding game module function
//     - game logic
//     - question generator
//
// List of Known Bugs:
//   - if a user double clicked on a country before the question appear,
//     the user will get an instance wrong answer
//
// Dependencies:
//   - cocos2d framework
//	 - sqlite3 framework
//
// Last edtied by Alex Bumbac
//   Date: Nov 17, 2009
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
#import "gameEurope.h"
#import "mainMenuScene.h"
#import "cocoslive.h"
#import <UIKit/UIKit.h>


enum {
	kTagTileMap = 1,
	kTagBitmapAtlas3 = 2,
	ktagcLabel= 3,
	ktagwLabel= 4,
	quitMenuTag = 5,
	quitPromptTag = 6,
	stageCompletePromptTag = 7,
	stageCompletePromptImageTag = 8,
};

// Explore implementation
@implementation gameEurope

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	gameEurope *layer = [gameEurope node];
	
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
	
	if (tapCount == 2) {
		CGPoint touchLocation = [touch locationInView: [touch view]];	
		CGPoint convertedPoint = [[Director sharedDirector] convertToGL:touchLocation];
		
		id map = [self getChildByTag:kTagTileMap];
		//TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"worldMap.tmx"];
		TMXLayer *namepop = [map layerNamed:@"tileId"];
		
		CGPoint addtest = ccpSub(convertedPoint, currentPos);
		
		unsigned int test = [namepop tileGIDAt:ccp((int)(addtest.x / (int)(32*zoomFactor)),((mapLayerSize.height-1) - (int)addtest.y / (int)(32*zoomFactor)))];
		
		
		if (test==0)
		{
			
		}
		else
		{
			[self gameLogic:test];
		}
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
	CocosNode *node = [self getChildByTag:kTagTileMap];
	currentPos = [node position];
	
	heightPixels = (((mapLayerSize.height*(32*zoomFactor))-320)+8);
	//widthPixels =	(((mapLayerSize.width*(32*zoomFactor))-480)+8);
	widthPixels = (5632*zoomFactor);
	
	//Check for bottom left corner
	if ((currentPos.x>-(4096*zoomFactor))&&(currentPos.y>-(3200*zoomFactor))) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(4115*zoomFactor), -(3220*zoomFactor))]];
	}
	//check for top left corner
	else if ((currentPos.x>-(4096*zoomFactor))&&(currentPos.y<-heightPixels)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-4115, -(heightPixels-8))]];
	}
	//check for bottom right corner
	else if ((currentPos.x<-widthPixels)&&((currentPos.y*zoomFactor)>-(3200*zoomFactor))) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), -(3220*zoomFactor))]];
	}
	//check for top right corner
	else if ((currentPos.x<-widthPixels)&&(currentPos.y<-heightPixels)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(widthPixels-8), -(heightPixels-8))]];
	}
	//Left Side Check to make sure the user can't go any farther left
	else if (currentPos.x>-(4096*zoomFactor)) 
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(-(4115*zoomFactor), currentPos.y)]];
	}
	//bottem check to make sure user can't go down too far
	else if(currentPos.y>-(3200*zoomFactor))
	{
		[node runAction:[MoveTo actionWithDuration: 0.2f position:ccp(currentPos.x, -(3220*zoomFactor))]];
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
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
		else if(yCoord==10)
		{
			for (int x=0; x<2; x++)
			{
				for (int y=-1; y<1; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
		if(yCoord==10)
		{
			for (int x=-1; x<1; x++)
			{
				for (int y=-1; y<1; y++)
				{
					if (isLoaded[xCoord+x][yCoord+y]==FALSE) 
					{
						NSString* nextTileString = [NSString stringWithFormat:@"%d_%d.tmx",xCoord+x,yCoord+y];
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
						TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
					TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
					TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
					TMXTiledMap *nextTile = [TMXTiledMap tiledMapWithTMXFile:nextTileString];
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
	TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"worldMap.tmx"];
	map.position = ccp(-5500,-3500);
	[self addChild:map z:0 tag:kTagTileMap];
	
	//Sets the size of layer
	TMXLayer *mapLayer = [map layerNamed:@"tileId"];
	mapLayerSize = [mapLayer layerSize];
	mapLayer.visible = NO;
	
}

// Generate a new question after the previous question is answered
-(void)questionGenerator
{
	if (questionCount==0||questionCount>=10||stage>=4)
	{
		[self setStage];
	}
	
	if (stage>=4)
	{
		NSString *hold = [myMutableArray objectAtIndex:0];
		
		NSString *stringRight = [NSString stringWithFormat: @"right:" "%d", right];
		NSString *stringWrong = [NSString stringWithFormat: @"wrong:" "%d", wrong];
		
		Label *label = (Label*) [self getChildByTag:kTagBitmapAtlas3];
		[label setString:hold];
		
		Label *label1 = (Label*) [self getChildByTag:ktagwLabel];
		[label1 setString:stringWrong];
		
		Label *label2 = (Label*) [self getChildByTag:ktagcLabel];
		[label2 setString:stringRight];
		
	}
	else
	{
		NSString *hold = [myMutableArray objectAtIndex:questionCount];
		
		NSString *stringRight = [NSString stringWithFormat: @"right:" "%d", right];
		NSString *stringWrong = [NSString stringWithFormat: @"wrong:" "%d", wrong];
		
		Label *label = (Label*) [self getChildByTag:kTagBitmapAtlas3];
		[label setString:hold];
		
		Label *label1 = (Label*) [self getChildByTag:ktagwLabel];
		[label1 setString:stringWrong];
		
		Label *label2 = (Label*) [self getChildByTag:ktagcLabel];
		[label2 setString:stringRight];
		
		questionCount++;
	}
}


//Game Logic 
// - select right/wrong country
// - will do incrementation in here
-(void)gameLogic:(unsigned int)input
{
	//Clicked on empty space (ocean) area
	if(input==0)
	{
		//do nothing
	}
	//Clicked on the correct country
	else if(answerID[0]==input&&stage>=4)
	{
		right++;
	}
	else if(answerID[questionCount-1]==input)
	{
		right++;
	}
	//Clicked on a wrong country
	else
	{
		wrong++;
	}
	
	if(wrong > 5)
	{
		[self gameOver];
		return;
	}
	
	[self questionGenerator];
}

//Initialize the stage
-(void) setStage
{
	int x=0;
	myMutableArray = [[NSMutableArray alloc] initWithCapacity:10];
	if(questionCount >= 10 && stage < 4)
	{
		stage++;
		questionCount = 0;
		wrong = 0;
		Sprite *stageCompletePrompt = [Sprite spriteWithFile:@"stageCompletePrompt.png"];
		[self addChild:stageCompletePrompt z:1 tag:stageCompletePromptImageTag];
		stageCompletePrompt.position = ccp(480/2,320-160);
		
		MenuItemImage *continuePromtButton = [MenuItemImage itemFromNormalImage:@"continue.png" selectedImage:@"continueClicked.png"  target:self selector:@selector(continue:)];
		
		Menu *continuePromt = [Menu menuWithItems:continuePromtButton, nil];
		
		continuePromt.position = CGPointZero;
		continuePromtButton.position = ccp(480/2,320-202);		
		[self addChild: continuePromt z:2 tag:stageCompletePromptTag];
		
		
		
	}
	
	if (continent == 0)
	{
		query = [NSString stringWithFormat: @"SELECT * FROM worldMap"];
	}
	else
	{
		query = [NSString stringWithFormat: @"SELECT * FROM worldMap WHERE continent = %d", continent];
	}
	if (stage < 4)
	{
		NSString *stageString = [NSString stringWithFormat: @" AND difficulty = %d ORDER BY Random() LIMIT 10", stage];
		query = [query stringByAppendingString: stageString];
	}
	else 
	{
		NSString *stageString = [NSString stringWithFormat: @" ORDER BY Random() LIMIT 1", stage];
		query = [query stringByAppendingString: stageString];
	}
	
	//get # of rows
	querySet = [db executeQuery: query];
	while ([querySet next]) {
		answerID[x] = [querySet intForColumn: @"Id"];
		countryName = [querySet stringForColumn:@"countryName"];
		[myMutableArray insertObject: countryName atIndex:x];
		
		x++;
	}
	[querySet close];
	
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{
		
		//setting Variables
		right = 0;
		wrong = 0;
		stage = 1;
		continent = 3;
		questionCount=0;
		
		//Enables touch
		self.isTouchEnabled = YES;
		
		zoomFactor = 1;
		
		//retrieves size of the window.
		CGSize s = [[Director sharedDirector] winSize];
		
		//set background
		Sprite *background = [Sprite spriteWithFile:@"background.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
		Sprite *labelBackground = [Sprite spriteWithFile:@"gameLabel.png"];
		[self addChild:labelBackground z:1];
		labelBackground.position = ccp(s.width/2,s.height-40);
		Label *where = [Label labelWithString:@"Where is:" fontName:@"comic_andy" fontSize:40];
		//set font colour
		[where setColor:ccc3(0, 0, 0)];
		//sets the label position
		where.position = ccp(s.width/2,s.height-25);
		//Adds label to scene
		[self addChild:where z:1];
		
		//Creates a Blank Label to be updated later
		Label *label = [Label labelWithString:@"" fontName:@"comic_andy" fontSize:40];
		//set font colour
		[label setColor:ccc3(0, 0, 0)];
		//sets the label position
		label.position = ccp(s.width/2,s.height-50);
		//Adds label to scene
		[self addChild:label z:1 tag:kTagBitmapAtlas3];
		
		Label *correctLabel = [Label labelWithString:@"0" fontName:@"comic_andy" fontSize:40];
		//set font colour
		[correctLabel setColor:ccc3(0, 0, 0)];
		//sets the label position
		correctLabel.position = ccp(s.width/2+170,s.height-25);
		//Adds label to scene
		[self addChild:correctLabel z:1 tag:ktagcLabel];
		
		Label *wrongLabel = [Label labelWithString:@"0" fontName:@"comic_andy" fontSize:40];
		//set font colour
		[wrongLabel setColor:ccc3(0, 0, 0)];
		//sets the label position
		wrongLabel.position = ccp(s.width/2-170,s.height-25);
		//Adds label to scene
		[self addChild:wrongLabel z:1 tag:ktagwLabel];
		
		[self loadMaps];
		
		MenuItemImage *zoomin = [MenuItemImage itemFromNormalImage:@"zoomin.png" selectedImage:@"zoominClicked.png"  target:self selector:@selector(zoomIn:)];
		MenuItemImage *zoomout = [MenuItemImage itemFromNormalImage:@"zoomout.png" selectedImage:@"zoomoutClicked.png"  target:self selector:@selector(zoomOut:)];
		MenuItemImage *quit = [MenuItemImage	itemFromNormalImage:@"quit.png" selectedImage:@"quitClicked.png" target:self selector:@selector(quitButton:)];
		
		Menu *menu = [Menu menuWithItems:quit, zoomout, zoomin, nil];
		
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
		
		//** start
		
		[self questionGenerator];
		//** end
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

- (void) gameOver
{
	Sprite *quitPrompt = [Sprite spriteWithFile:@"gameoverPrompt.png"];
	[self addChild:quitPrompt z:1 tag:quitPromptTag];
	quitPrompt.position = ccp(480/2,320-160);
	
	MenuItemImage *finish = [MenuItemImage itemFromNormalImage:@"finish.png" selectedImage:@"finishClicked.png"  target:self selector:@selector(quit:)];
	MenuItemImage *score = [MenuItemImage itemFromNormalImage:@"submitscore.png" selectedImage:@"submitscoreClicked.png"  target:self selector:@selector(enterName:)];
	Menu *finishMenu = [Menu menuWithItems:score, finish, nil];
	finishMenu.position = CGPointZero;
	finish.position = ccp(480/2+65,320-175);
	score.position = ccp(480/2-33,320-175);
	
	[self addChild: finishMenu z:2];
	
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [myText resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing: (UITextField *)textField {
    if(textField == myText) {
        [myText endEditing:YES];
        [myText removeFromSuperview];
        playerName = myText.text;
        NSLog([NSString stringWithFormat:@"entered: %@", playerName]);
		[self postScore];
    } else {
        NSLog(@"textField did not match myText");
    }
}

-(void) postScore//:(NSInteger)cate
{
	NSLog(@"Posting Score");
	
	// Create que "post" object for the game "DemoGame 3"
	// The gameKey is the secret key that is generated when you create you game in cocos live.
	// This secret key is used to prevent spoofing the high scores
	ScoreServerPost *server = [[ScoreServerPost alloc] initWithGameName:@"iGeo" gameKey:@"ea440695bcf66a83100b23a888e3d9df" delegate:self];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	// Name at random
	//NSArray *names = [NSArray arrayWithObjects:@"いすの上に猫がいる", @"Carrière", @"Iñaqui", @"Clemensstraße München ", @"有一只猫在椅子上", nil];
	//NSString *name = [names objectAtIndex: CCRANDOM_0_1() * 5];
	
	// cc_ files are predefined cocoslive fields.
	// set score
	[dict setObject: [NSNumber numberWithInt: right] forKey:@"cc_score"];
	
	// set playername
	[dict setObject:playerName forKey:@"cc_playername"];
	
	// usr_ are fields that can be modified.
	// set speed
	//[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:2000] ] forKey:@"usr_speed"];
	// set angle
	//[dict setObject: [NSNumber numberWithInt:[self getRandomWithMax:360] ] forKey:@"usr_angle"];
	
	
	// cc_ are fields that cannot be modified. cocos fields
	// set category... it can be "easy", "medium", whatever you want.
	NSString *cat = @"pants";
	switch(continent) {
		case 0:
			cat = @"WholeWorld";
			break;
		case 1:
			cat = @"Americas";
			break;
		case 3:
			cat = @"Europe";
			break;
		case 4:
			cat = @"Africa";
			break;
		case 5:
			cat = @"Asia/Oceania";
			break;
	}
	[dict setObject:cat forKey:@"cc_category"];
	NSLog(@"Sending data: %@", dict);
	
	// You can add a new score to the database
	//	[server sendScore:dict];
	
	// Or you can "update" your score instead of adding a new one.
	// The score will be udpated only if it is better than the previous one
	// 
	// "update score" is the recommend way since it can be treated like a profile
	// and it has some benefits like: "tell me if my score was beaten", etc.
	// It also supports "world ranking". eg: "What's my ranking ?"
	[server updateScore:dict];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[server release];
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}


- (void)enterName: (id) sender
{
	myText = [[UITextField alloc] initWithFrame:CGRectMake(120, 120, 160, 240)];
	
	CGAffineTransform transform=CGAffineTransformMakeRotation(3.14/2);
	myText.transform = transform;
	
	[myText setDelegate:self];
	[myText setText:@""];
	[myText setTextColor: [UIColor colorWithRed:255 green:255 blue:255 alpha:1.0]];
	[[[[Director sharedDirector] openGLView] window] addSubview:myText];
	[myText becomeFirstResponder];
}

//function what to do when click yes
- (void)quit: (id) sender
{
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}

- (void)continue: (id) sender
{
	CocosNode *rem1 = [self getChildByTag:stageCompletePromptTag];
	CocosNode *rem2 = [self getChildByTag:stageCompletePromptImageTag];
	[self removeChild: rem1 cleanup: YES];
	[self removeChild: rem2 cleanup: YES];
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