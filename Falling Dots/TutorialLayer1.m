//
//  TutorialLayer1.m
//  Falling Dots
//
//  Created by Victor Zhou on 6/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TutorialLayer1.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation TutorialLayer1

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	TutorialLayer1 *layer = [TutorialLayer1 node];
	[scene addChild: layer];
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        top = [CCSprite spriteWithFile:@"tutorial_top.png"];
        top.position = ccp(160, 2*CENTERY+9);
        [self addChild:top];
        [self reorderChild:top z:999];
        
        dot = [CCSprite spriteWithFile:@"tutorial_dotBlack.png"];
        dot.position = ccp(160, CENTERY);
        [self addChild:dot];
        dot.opacity = 0;
        
        ready = [CCMenuItemImage itemWithNormalImage:@"tutorial_ready.png" selectedImage:@"tutorial_readySelected.png" target:self selector:@selector(ready)];
        readyMenu = [CCMenu menuWithItems:ready, nil];
        readyMenu.position = ccp(160, 50-1000);
        [self addChild:readyMenu];
        
        [self scheduleOnce:@selector(animateIn) delay:.8];
    }
    return self;
}

-(void)animateIn
{
    [top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
    [readyMenu runAction:[CCMoveTo actionWithDuration:3 position:CGPointMake(160, 50)]];
    [self scheduleOnce:@selector(fadeInDot) delay:.5];
}
-(void)fadeInDot
{
    [dot runAction:[CCFadeIn actionWithDuration:.5]];
}
-(void)ready
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPlayedBefore"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuLayer scene] withColor:ccWHITE]];}
@end
