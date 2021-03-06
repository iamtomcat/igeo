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
#import "playMenuScene.h"

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
		
        [MenuItemFont setFontSize:45];
        [MenuItemFont setFontName:@"comic_andy"];
		MenuItem *wholeWorld = [MenuItemFont itemFromString:@"Whole World" target:self selector:@selector(wholeWorld:)];
		MenuItem *americas = [MenuItemFont itemFromString:@"Americas" target:self selector:@selector(selectAmercias:)];
		MenuItem *europe = [MenuItemFont itemFromString:@"Europe" target:self selector:@selector(selectEurope:)];
        MenuItem *africa = [MenuItemFont itemFromString:@"Africa" target:self selector:@selector(selectAfrica:)];
        MenuItem *asia = [MenuItemFont itemFromString:@"Asia" target:self selector:@selector(selectAsia:)];
        MenuItem *oceania = [MenuItemFont itemFromString:@"Oceania" target:self selector:@selector(selectOceania:)];
        Menu *menu = [Menu menuWithItems:wholeWorld, americas, europe, africa, asia, oceania, nil];
		[menu setColor:ccc3(0, 0, 0)]; 
		[menu alignItemsVerticallyWithPadding:2];
		menu.position = ccp(350,167);
		[self addChild:menu];
		
		MenuItemImage *backButton = [MenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton2.png"  target:self selector:@selector(back:)]; 
		Menu *backB =[Menu menuWithItems: backButton, nil];
		backB.position = ccp(35,35);
		[self addChild:backB];
    }
    return self;
}

//not implemented in version 1
-(void)wholeWorld: (id)sender {
    //place holder for future code
}
-(void)selectAmercias: (id)sender {
}
-(void)selectEurope: (id)sender {
}
-(void)selectAfrica: (id)sender {
}
-(void)selectAsia: (id)sender {
}
-(void)selectOceania: (id)sender {
}
-(void)back: (id)sender {
	playMenuScene * pms = [playMenuScene node];
    [[Director sharedDirector] replaceScene:pms];
}


-(void)help: (id)sender {
    NSLog(@"help");
}

@end
