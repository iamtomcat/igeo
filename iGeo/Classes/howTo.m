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

#import "howTo.h"
#import "mainMenuScene.h"

@implementation howTo

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	howTo *layer = [howTo node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
	
    self = [super init];
    if (self != nil) {
		
		pageNumber = 0;
		for (int x=0; x<5; x++)
		{
			pageTag[x] = x;
		}
		
		Sprite *page = [Sprite spriteWithFile:@"tutorial_0.png"];
		[self addChild:page z:-1 tag:pageTag[pageNumber]];
		page.position = ccp(240, 160);
		
        MenuItemImage *next = [MenuItemImage itemFromNormalImage:@"tutnext.png" selectedImage:@"tutnextClicked.png"  target:self selector:@selector(next:)];
        MenuItemImage *previous = [MenuItemImage itemFromNormalImage:@"tutprevious.png" selectedImage:@"tutpreviousClicked.png"  target:self selector:@selector(previous:)];
		MenuItemImage *quit = [MenuItemImage itemFromNormalImage:@"quit.png" selectedImage:@"quitClicked.png"  target:self selector:@selector(quit:)];
		Menu *menu = [Menu menuWithItems:quit, previous, next, nil];
		
		menu.position = CGPointZero;
		
		previous.position = ccp(480/2 - 148,30);
		next.position = ccp(480/2 + 180,30);
		quit.position = ccp(480/2 - 217,30);
		
		[self addChild:menu];

    }
    return self;
}

-(void)next: (id)sender {
	if (pageNumber < 4)
	{
		pageNumber++;
		NSString* pageNumberString = [NSString stringWithFormat:@"tutorial_%d.png",pageNumber];
		NSLog(pageNumberString);
		Sprite *page = [Sprite spriteWithFile:pageNumberString];
		[self addChild:page z:-1 tag:pageTag[pageNumber]];
		page.position = ccp(240, 160);
	
		CocosNode *rem1 = [self getChildByTag:pageTag[pageNumber-1]];
		[self removeChild: rem1 cleanup: YES];
	}
	else
	{
	}
}
 
-(void)previous: (id)sender {
	if (pageNumber > 0)
	{
		pageNumber--;
		NSString* pageNumberString = [NSString stringWithFormat:@"tutorial_%d.png",pageNumber];
		NSLog(pageNumberString);
		Sprite *page = [Sprite spriteWithFile:pageNumberString];
		[self addChild:page z:-1 tag:pageTag[pageNumber]];
		page.position = ccp(240, 160);
		
		CocosNode *rem1 = [self getChildByTag:pageTag[pageNumber+1]];
		[self removeChild: rem1 cleanup: YES];
	}
	else
	{
	}

}
- (void)quit: (id) sender
{
	mainMenuScene * mms = [mainMenuScene node];
    [[Director sharedDirector] replaceScene:mms];
}

@end
