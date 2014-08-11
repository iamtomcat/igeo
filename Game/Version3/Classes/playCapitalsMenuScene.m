//
// playCapitalsMenuScene.m
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

#import "playCapitalsMenuScene.h"
#import "playCapitalsContinentSelectionScene.h"

@implementation playCapitalsMenuScene
+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	playCapitalsMenuScene *layer = [playCapitalsMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
    self = [super init];
    if (self != nil) {
		Sprite *background = [Sprite spriteWithFile:@"playSubMenu.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
        [MenuItemFont setFontSize:20];
        [MenuItemFont setFontName:@"Helvetica"];
		MenuItem *wholeWorld = [MenuItemFont itemFromString:@"Whole World" target:self selector:@selector(wholeWorld:)];
        MenuItem *continent = [MenuItemFont itemFromString:@"Continents" target:self selector:@selector(continent:)];
        Menu *menu = [Menu menuWithItems:wholeWorld, continent, nil];
		[menu alignItemsVerticallyWithPadding:30];
		menu.position = ccp(350,190);
		[self addChild:menu];
    }
    return self;
}

//not implemented in version 1
-(void)wholeWorld: (id)sender {
    //place holder for future code
}
-(void)continent: (id)sender {
    playCapitalsContinentSelectionScene * pccss = [playCapitalsContinentSelectionScene node];
	[[Director sharedDirector] replaceScene:pccss];
}


-(void)help: (id)sender {
    NSLog(@"help");
}

@end
