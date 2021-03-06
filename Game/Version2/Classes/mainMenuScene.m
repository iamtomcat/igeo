//
// mainMenuScene.m
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

#import "mainMenuScene.h"
#import "Explore.h"
#import "playMenuScene.h"
#import "game.h"

@implementation mainMenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	mainMenuScene *layer = [mainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
    self = [super init];
    if (self != nil) {
		Sprite *background = [Sprite spriteWithFile:@"mainMenu.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
		
        [MenuItemFont setFontSize:45];
        [MenuItemFont setFontName:@"comic_andy"];
        MenuItem *start = [MenuItemFont itemFromString:@"Explore" target:self selector:@selector(explore:)];
        MenuItem *play = [MenuItemFont itemFromString:@"Play" target:self selector:@selector(play:)];
		MenuItem *howto = [MenuItemFont itemFromString:@"How To" target:self selector:@selector(howto:)];
		MenuItem *score = [MenuItemFont itemFromString:@"High Score" target:self selector:@selector(highScore:)];
		Menu *menu = [Menu menuWithItems:start, play, howto, score, nil];
        [menu setColor:ccc3(0, 0, 0)]; 
		//[menu alignItemsVertically];
		[menu alignItemsVerticallyWithPadding:7];
		menu.position = ccp(350,167);
        [self addChild:menu];
    }
    return self;
}
-(void)explore: (id)sender {
    Explore * es = [Explore node];
    [[Director sharedDirector] replaceScene:es];
}
-(void)play: (id)sender {
    playMenuScene * pms = [playMenuScene node];
    [[Director sharedDirector] replaceScene:pms];
}
//Place Holder
-(void)howto: (id)sender {
	Game * hts = [Game node];
    [[Director sharedDirector] replaceScene:hts];
   }

-(void)highScore: (id)sender {
//Not used in version 1
}

@end
