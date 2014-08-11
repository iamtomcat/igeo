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
#import "playCapitalsMenuScene.h"
#import "playCountriesMenuScene.h"
#import "mainMenuScene.h"

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
		Sprite *background = [Sprite spriteWithFile:@"playMenu.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
        [MenuItemFont setFontSize:45];
        [MenuItemFont setFontName:@"comic_andy"];
        MenuItem *countries = [MenuItemFont itemFromString:@"Countries" target:self selector:@selector(countriesMenu:)];
		MenuItem *capitals = [MenuItemFont itemFromString:@"Capitals" target:self selector:@selector(capitalsMenu:)];
		MenuItem *quickPlay = [MenuItemFont itemFromString:@"QuickPlay" target:self selector:@selector(quickPlay:)];
        Menu *menu = [Menu menuWithItems:countries, capitals, quickPlay, nil];
		[menu setColor:ccc3(0, 0, 0)]; 
		[menu alignItemsVerticallyWithPadding:5];
		menu.position = ccp(350,167);
		[self addChild:menu];
		
		MenuItemImage *backButton = [MenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton2.png"  target:self selector:@selector(back:)]; 
		Menu *backB =[Menu menuWithItems: backButton, nil];
		backB.position = ccp(35,35);
		[self addChild:backB];
    }
    return self;
}
-(void)countriesMenu: (id)sender {
    playCountriesMenuScene * cms = [playCountriesMenuScene node];
    [[Director sharedDirector] replaceScene:cms];
}
-(void)capitalsMenu: (id)sender {
    playCapitalsMenuScene * gs = [playCapitalsMenuScene node];
    [[Director sharedDirector] replaceScene:gs];
}
-(void)quickPlay: (id)sender {
}
-(void)back: (id)sender {
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}

-(void)help: (id)sender {
    NSLog(@"help");
}

@end
