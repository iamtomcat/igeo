//
// playMenuScene.m
// iGeo
//
// Team iGeo
//
// Created by Tom Clark 05-10-09
//
// Version 1.0
//   Edited by Tom Clark, Angad Soni
//   Changes:
//   - Creation
//   - Implemented Menu Linking
// 
// List of Known Bugs:
//   - No back button
//   - Mention: Only 'Explore' button under main is a live link
//
// Dependencies:
//   - cocos2d framework
//
// Last edtied by Alex Bumbac
//   Date: Nov 05, 2009
//   Time: 3:00 PM
//
// Copyright Simon Fraser University 2009, All right reserved.
//

#import "playMenuScene.h"
#import "mainMenuScene.h"
#import "gameAmerica.h"
#import "gameEurope.h"
#import "gameAsiaOceania.h"
#import "gameAfrica.h"
#import "gameWholeWorld.h"

@implementation playMenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	playMenuScene *layer = [playMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
    self = [super init];
    if (self != nil) {
		Sprite *background = [Sprite spriteWithFile:@"menuBackground.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
		MenuItemImage *wholeworld = [MenuItemImage itemFromNormalImage:@"wholeworld.png" selectedImage:@"wholeworldClicked.png"  target:self selector:@selector(selectWholeWorld:)];
        MenuItemImage *americas = [MenuItemImage itemFromNormalImage:@"americas.png" selectedImage:@"americasClicked.png"  target:self selector:@selector(selectAmercias:)];
		MenuItemImage *europe = [MenuItemImage itemFromNormalImage:@"europe.png" selectedImage:@"europeClicked.png"  target:self selector:@selector(selectEurope:)];
		MenuItemImage *africa = [MenuItemImage itemFromNormalImage:@"africa.png" selectedImage:@"africaClicked.png"  target:self selector:@selector(selectAfrica:)];
		MenuItemImage *asiaoceania = [MenuItemImage itemFromNormalImage:@"asiaoceania.png" selectedImage:@"asiaoceaniaClicked.png"  target:self selector:@selector(selectAsiaOceania:)];
        MenuItemImage *quickplay = [MenuItemImage itemFromNormalImage:@"quickplay.png" selectedImage:@"quickplayClicked.png"  target:self selector:@selector(quickplay:)];
		Menu *menu = [Menu menuWithItems:wholeworld, americas, europe, africa, asiaoceania, quickplay, nil];
		[menu alignItemsVertically];
		menu.position = ccp(350,167);
        [self addChild:menu];
		
		MenuItemImage *backButton = [MenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"backClicked.png"  target:self selector:@selector(back:)]; 
		Menu *backB =[Menu menuWithItems: backButton, nil];
		backB.position = ccp(35,35);
		[self addChild:backB];
    }
    return self;
}
-(void)selectWholeWorld: (id)sender 
{
	gameWholeWorld *wW = [gameWholeWorld node];
    [[Director sharedDirector] replaceScene:wW];
}
-(void)selectAmercias: (id)sender 
{
	gameAmerica *gA = [gameAmerica node];
    [[Director sharedDirector] replaceScene:gA];
}
-(void)selectEurope: (id)sender 
{
	gameEurope *gE = [gameEurope node];
    [[Director sharedDirector] replaceScene:gE];
}
-(void)selectAfrica: (id)sender 
{
	gameAfrica *gAf = [gameAfrica node];
    [[Director sharedDirector] replaceScene:gAf];
}
-(void)selectAsiaOceania: (id)sender 
{
	gameAsiaOceania *gAO = [gameAsiaOceania node];
    [[Director sharedDirector] replaceScene:gAO];
}
-(void)quickplay: (id)sender
{
	int randomStage = 1 + arc4random() % ((5+1)-1);
	
	gameWholeWorld *wW = [gameWholeWorld node];
	gameAmerica *gA = [gameAmerica node];
	gameEurope *gE = [gameEurope node];
	gameAfrica *gAf = [gameAfrica node];
	gameAsiaOceania *gAO = [gameAsiaOceania node];

	switch(randomStage) {
		case 1:
			[[Director sharedDirector] replaceScene:wW];
			break;
		case 2:
			[[Director sharedDirector] replaceScene:gA];
			break;
		case 3:
			[[Director sharedDirector] replaceScene:gE];
			break;
		case 4:
			[[Director sharedDirector] replaceScene:gAf];
			break;
		case 5:
			[[Director sharedDirector] replaceScene:gAO];
			break;
	}			
	
	
}
-(void)back: (id)sender {
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}

-(void)help: (id)sender {
    NSLog(@"help");
}

@end
