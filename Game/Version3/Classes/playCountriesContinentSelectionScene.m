//
// playCountriesContinentSelectionScene.m
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
#import "playCountriesContinentSelectionScene.h"

@implementation playCountriesContinentSelectionScene
+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	playCountriesContinentSelectionScene *layer = [playCountriesContinentSelectionScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
    self = [super init];
    if (self != nil) {
		Sprite *background = [Sprite spriteWithFile:@"playContinentSelection.png"];
		background.position = ccp(240, 160);
		[self addChild:background z:-1];
		
        [MenuItemFont setFontSize:20];
        [MenuItemFont setFontName:@"Helvetica"];
        MenuItem *americas = [MenuItemFont itemFromString:@"Americas" target:self selector:@selector(selectAmercias:)];
		MenuItem *europe = [MenuItemFont itemFromString:@"Europe" target:self selector:@selector(selectEurope:)];
        MenuItem *africa = [MenuItemFont itemFromString:@"Africa" target:self selector:@selector(selectAfrica:)];
        MenuItem *asia = [MenuItemFont itemFromString:@"Asia" target:self selector:@selector(selectAsia:)];
        MenuItem *oceania = [MenuItemFont itemFromString:@"Oceania" target:self selector:@selector(selectOceania:)];

        Menu *menu = [Menu menuWithItems:americas, europe, africa, asia, oceania, nil];
		[menu alignItemsVerticallyWithPadding:30];
		menu.position = ccp(350,162);
		[self addChild:menu];
    }
    return self;
}

//All countries not implemented in Version 1
//All are place holders
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

-(void)help: (id)sender {
    NSLog(@"help");
}

@end
