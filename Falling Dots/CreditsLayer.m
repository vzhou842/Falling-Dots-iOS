//
//  CreditsLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 7/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CreditsLayer.h"
#import "MainMenuLayer.h"
#import "AndrewJinLayer.h"
#import "GeorgeQiLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation CreditsLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	CreditsLayer *layer = [CreditsLayer node];
	[scene addChild: layer];
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        self.isTouchEnabled = YES;
        
        anchorPoint = CGPointMake(0, 0);
        
        background = [CCSprite spriteWithFile:@"background_personalStats.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        top = [CCSprite spriteWithFile:@"credits_top.png"];
        top.position = ccp(160, 2*CENTERY+9);
        [self addChild:top];
        [self reorderChild:top z:999];
        [top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
        
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-300,2*CENTERY-21);
        [self addChild:backMenu];
        [self reorderChild:backMenu z:1000];
        [backMenu runAction:[CCMoveTo actionWithDuration:2.4 position:CGPointMake(15, 2*CENTERY-21)]];
        
        
        //LABELS
        createdBy = [CCLabelTTF labelWithString:@"Created By:" fontName:@"Eurostile" fontSize:14];
        createdBy.anchorPoint = CGPointMake(0, 0);
        [self addChild:createdBy];
        createdBy.opacity = 0;
        createdBy.color = ccBLACK;
        createdBy.position = ccp(3, 1.6*CENTERY);
        
        victorZhou = [CCLabelTTF labelWithString:@"Victor Zhou" fontName:@"Eurostile" fontSize:44];
        victorZhou.anchorPoint = CGPointMake(.5, .5);
        [self addChild:victorZhou];
        victorZhou.opacity = 0;
        victorZhou.color = ccBLACK;
        victorZhou.position = ccp(160, 1.45*CENTERY);
        
        
        notableContributors = [CCLabelTTF labelWithString:@"Notable Contributors:" fontName:@"Eurostile" fontSize:14];
        notableContributors.anchorPoint = CGPointMake(0, 0);
        [self addChild: notableContributors];
        notableContributors.opacity = 0;
        notableContributors.color = ccBLACK;
        notableContributors.position = ccp(3, 1.13*CENTERY);
        
        listNotable = [CCLabelTTF labelWithString:@"Nabeel Muscatwalla\nVinci Chen\nJack Pigott\nGeorge Qi\nAthena Chen" fontName:@"Eurostile" fontSize:22];
        listNotable.anchorPoint = CGPointMake(.5, .5);
        [self addChild: listNotable];
        listNotable.opacity = 0;
        listNotable.color = ccBLACK;
        listNotable.position = ccp(160, .85*CENTERY);
        
        
        thanks = [CCLabelTTF labelWithString:@"Special Thanks:" fontName:@"Eurostile" fontSize:14];
        thanks.anchorPoint = CGPointMake(0, 0);
        [self addChild: thanks];
        thanks.opacity = 0;
        thanks.color = ccBLACK;
        thanks.position = ccp(3, .47*CENTERY);
        
        listThanks = [CCLabelTTF labelWithString:@"Kevin Tian\nRobert Tung\nVivian Zhou\nPaul Cruz\nAndrew Jin" fontName:@"Eurostile" fontSize:14];
        listThanks.anchorPoint = CGPointMake(.5, .5);
        [self addChild: listThanks];
        listThanks.opacity = 0;
        listThanks.color = ccBLACK;
        listThanks.position = ccp(160, .27*CENTERY);
        
        sponsors = [CCLabelTTF labelWithString:@"Proudly Sponsored by:" fontName:@"Eurostile" fontSize:14];
        sponsors.anchorPoint = CGPointMake(0, 0);
        [self addChild: sponsors];
        sponsors.opacity = 0;
        sponsors.color = ccBLACK;
        sponsors.position = ccp(3, -.2*CENTERY);
        
        IKS = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"IKS - COFER Corporation" fontName:@"Eurostile" fontSize:22]];
        amplifinderImage = [CCMenuItemImage itemWithNormalImage:@"amplifind.png" selectedImage:@"amplifind.png" target:self selector:@selector(amplifind)];
        francis = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Francis Zorrilla" fontName:@"Eurostile" fontSize:26] target:self selector:@selector(francis)];
        swansoft = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"What's the Word?\nLook at the 2 Pics &\nfind out what's the common word - Enjoy!" fontName:@"Eurostile" fontSize:16] target:self selector:@selector(swansoft)];
        [IKS setColor:ccBLACK];
        [francis setColor:ccBLACK];
        [swansoft setColor:ccBLACK];
        sponsorMenu = [CCMenu menuWithItems:IKS, amplifinderImage, francis, swansoft, nil];
        sponsorMenu.position = ccp(160, -1.5*CENTERY);
        [self addChild:sponsorMenu];
        [sponsorMenu alignItemsVerticallyWithPadding:20];
        sponsorMenu.opacity = 0;
        
        [self scheduleOnce:@selector(fadeInTop) delay:.25];
        [self scheduleOnce:@selector(fadeInMid) delay:.75];
        [self scheduleOnce:@selector(fadeInBot) delay:1.25];
        [self scheduleOnce:@selector(fadeInSponsors) delay:1.75];
    }
    return self;
}


-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}

-(void)fadeInTop
{
    [createdBy runAction:[CCFadeIn actionWithDuration:.75]];
    [victorZhou runAction:[CCFadeIn actionWithDuration:.75]];
}

-(void)fadeInMid
{
    [notableContributors runAction:[CCFadeIn actionWithDuration:.75]];
    [listNotable runAction:[CCFadeIn actionWithDuration:.75]];
}

-(void)fadeInBot
{
    [thanks runAction:[CCFadeIn actionWithDuration:.75]];
    [listThanks runAction:[CCFadeIn actionWithDuration:.75]];
}

-(void)fadeInSponsors
{
    [sponsors runAction:[CCFadeIn actionWithDuration:.75]];
    [sponsorMenu runAction:[CCFadeIn actionWithDuration:.75]];
}

-(void)jinz
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[AndrewJinLayer sceneForMode:ANDREW_JIN_MODE]]];
}

-(void)george
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[GeorgeQiLayer sceneForMode:GEORGE_QI_MODE]]];
}



-(void)amplifind
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/amplifind-music-player-visualizer/id705587544?ls=1&mt=8"]];
}
-(void)francis
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/bubble-bug-blaster-zen-tap/id477895420?mt=8"]];
}
-(void)swansoft
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/word-2-pics/id735969166?mt=8"]];
}

-(void)updateForAnchorPoint
{
    createdBy.position = ccp(3, anchorPoint.y+1.6*CENTERY);
    victorZhou.position = ccp(160, anchorPoint.y+1.45*CENTERY);
    notableContributors.position = ccp(3, anchorPoint.y+1.13*CENTERY);
    listNotable.position = ccp(160, anchorPoint.y+.85*CENTERY);
    thanks.position = ccp(3, anchorPoint.y+.47*CENTERY);
    listThanks.position = ccp(160, anchorPoint.y+.27*CENTERY);
    sponsors.position = ccp(3, anchorPoint.y-.2*CENTERY);
    sponsorMenu.position = ccp(160, anchorPoint.y-.8*CENTERY);
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.x >= 100 && location.y <= 220 && location.y <= 50)
    {
        jinzTaps++;
        if (jinzTaps >= JINZ_THRESHOLD)
            [self jinz];
    }
    else if (location.x >= 270 && location.y >= 2*CENTERY-50)
    {
        georgeTaps++;
        if (georgeTaps >= GEORGE_THRESHOLD)
            [self george];
    }
    
    startPoint = location;
    startAnchorPoint = anchorPoint;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    anchorPoint.y = startAnchorPoint.y+(location.y-startPoint.y);
    if (anchorPoint.y < 0) anchorPoint.y = 0;
    [self updateForAnchorPoint];
}


@end
