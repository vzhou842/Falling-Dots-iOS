//
//  MainMenuLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MultiplayerLayer.h"
#import "AppDelegate.h"
#import "InstructionsLayer.h"
#import "ChallengesLayer.h"
#import "StatsLayer.h"
#import "CreditsLayer.h"
#import "UpgradesLayer.h"
#import "ShopLayer.h"
#import "SettingsLayer.h"

#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation MainMenuLayer
@synthesize nextDotCreateDate;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MainMenuLayer *layer = [MainMenuLayer node];
	[scene addChild: layer];
	return scene;
}
- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init
{
    if (self = [super init])
    {
        self.isTouchEnabled = YES;
        
        //init equipped skins if needed
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_skin"] < 80)
            [[NSUserDefaults standardUserDefaults] setInteger:SKINS_DEFAULT forKey:@"equipped_skin"];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"] < 90)
            [[NSUserDefaults standardUserDefaults] setInteger:MENU_SKINS_DEFAULT forKey:@"equipped_menu_skin"];
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        /*backgroundOver = [CCSprite spriteWithFile:@"background_mainMenu.png"];
        backgroundOver.position = ccp(160, CENTERY*10);
        [self addChild:backgroundOver];
        [backgroundOver runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY)]];*/
        
        NSString *fallingFile = @"mainMenu_falling.png";
        if (CENTERY > 240) fallingFile = @"mainMenu_falling-tall.png";
        falling = [CCSprite spriteWithFile:fallingFile];
        falling.anchorPoint = CGPointMake(0, 0);
        falling.position = ccp(0, 4*CENTERY);
        [self addChild:falling];
        [self reorderChild:falling z:10];
        [falling runAction:[CCMoveTo actionWithDuration:.35 position:CGPointMake(0, 0)]];
        [self scheduleOnce:@selector(createDustFalling) delay:.4];
        
        dots = [CCSprite spriteWithFile:@"mainMenu_dots.png"];
        dots.anchorPoint = CGPointMake(1, 0);
        dots.position = ccp(320, 10*CENTERY);
        [self addChild:dots];
        [self reorderChild:dots z:10];
        [dots runAction:[CCMoveTo actionWithDuration:.9 position:CGPointMake(320, 0)]];
        [self scheduleOnce:@selector(createDustDots) delay:1];
        
        
        particlesArray = [[NSMutableArray alloc] init];
        dotsArray = [[NSMutableArray alloc] init];
        dotExplosionsArray = [[NSMutableArray alloc] init];
        [self schedule:@selector(update) interval:1/30.0];
        
        
        currentAvgDensity = .8;
        currentAvgBaseSpeed = 120;
        self.nextDotCreateDate = [NSDate dateWithTimeIntervalSinceNow:4];
        elapsedTime = 0;
        
        
        classic = [CCMenuItemImage itemWithNormalImage:@"mainMenu_classicMode.png" selectedImage:@"mainMenu_classicModeSelected.png" target:self selector:@selector(classic)];
        arcade = [CCMenuItemImage itemWithNormalImage:@"mainMenu_arcadeMode.png" selectedImage:@"mainMenu_arcadeModeSelected.png" target:self selector:@selector(arcade)];
        multiplayer = [CCMenuItemImage itemWithNormalImage:@"mainMenu_multiplayerMode.png" selectedImage:@"mainMenu_multiplayerModeSelected.png" target:self selector:@selector(multiplayer)];
        challenges = [CCMenuItemImage itemWithNormalImage:@"mainMenu_challenges.png" selectedImage:@"mainMenu_challengesSelected.png" target:self selector:@selector(challenges)];
        leaderboards = [CCMenuItemImage itemWithNormalImage:@"mainMenu_leaderboards.png" selectedImage:@"mainMenu_leaderboardsSelected.png" target:self selector:@selector(showLeaderboards)];
        instructions = [CCMenuItemImage itemWithNormalImage:@"mainMenu_instructions.png" selectedImage:@"mainMenu_instructionsSelected.png" target:self selector:@selector(instructions)];
        back = [CCMenuItemImage itemWithNormalImage:@"mainMenu_back.png" selectedImage:@"mainMenu_backSelected.png" target:self selector:@selector(back)];
        play = [CCMenuItemImage itemWithNormalImage:@"mainMenu_play.png" selectedImage:@"mainMenu_playSelected.png" target:self selector:@selector(play)];
        personalStats = [CCMenuItemImage itemWithNormalImage:@"mainMenu_personalStats.png" selectedImage:@"mainMenu_personalStatsSelected.png" target:self selector:@selector(personalStats)];
        credits = [CCMenuItemImage itemWithNormalImage:@"mainMenu_credits.png" selectedImage:@"mainMenu_creditsSelected.png" target:self selector:@selector(credits)];
        upgrades = [CCMenuItemImage itemWithNormalImage:@"mainMenu_upgrades.png" selectedImage:@"mainMenu_upgradesSelected.png" target:self selector:@selector(upgrades)];
        shop = [CCMenuItemImage itemWithNormalImage:@"mainMenu_shop.png" selectedImage:@"mainMenu_shopSelected.png" target:self selector:@selector(shop)];
        more = [CCMenuItemImage itemWithNormalImage:@"mainMenu_more.png" selectedImage:@"mainMenu_moreSelected.png" target:self selector:@selector(more)];
        settings = [CCMenuItemImage itemWithNormalImage:@"mainMenu_settings.png" selectedImage:@"mainMenu_settingsSelected.png" target:self selector:@selector(settings)];
        freePoints = [CCMenuItemImage itemWithNormalImage:@"mainMenu_freePoints.png" selectedImage:@"mainMenu_freePointsSelected.png" target:self selector:@selector(freePoints)];
        classicMenu = [CCMenu menuWithItems:classic, nil];
        classicMenu.position = ccp(268+1900, CENTERY+165);
        arcadeMenu = [CCMenu menuWithItems:arcade, nil];
        arcadeMenu.position = ccp(268+2200, CENTERY+105);
        multiplayerMenu = [CCMenu menuWithItems:multiplayer, nil];
        multiplayerMenu.position = ccp(268+2500, CENTERY+45);
        challengesMenu = [CCMenu menuWithItems:challenges, nil];
        challengesMenu.position = ccp(268+2500, CENTERY-75);
        leaderboardsMenu = [CCMenu menuWithItems:leaderboards, nil];
        leaderboardsMenu.position = ccp(268+2200, CENTERY-15);
        instructionsMenu = [CCMenu menuWithItems:instructions, nil];
        instructionsMenu.position = ccp(268+2800, CENTERY-135);
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(268+1600, CENTERY+165);
        playMenu = [CCMenu menuWithItems:play, nil];
        playMenu.position = ccp(268+1600, CENTERY+165);
        personalStatsMenu = [CCMenu menuWithItems:personalStats, nil];
        personalStatsMenu.position = ccp(268+2200, CENTERY+45);
        creditsMenu = [CCMenu menuWithItems:credits, nil];
        creditsMenu.position = ccp(268+2800, CENTERY-135);
        upgradesMenu = [CCMenu menuWithItems:upgrades, nil];
        upgradesMenu.position = ccp(268+1900, CENTERY+105);
        shopMenu = [CCMenu menuWithItems:shop, nil];
        shopMenu.position = ccp(268+2800, CENTERY-135);
        moreMenu = [CCMenu menuWithItems:more, nil];
        moreMenu.position = ccp(268+2800, CENTERY-75);
        settingsMenu = [CCMenu menuWithItems:settings, nil];
        settingsMenu.position = ccp(268+2800, CENTERY-75);
        freePointsMenu = [CCMenu menuWithItems:freePoints, nil];
        freePointsMenu.position = ccp(268+1900, CENTERY+105);
        [self addChild:classicMenu];
        [self addChild:arcadeMenu];
        [self addChild:multiplayerMenu];
        [self addChild:challengesMenu];
        [self addChild:leaderboardsMenu];
        [self addChild:instructionsMenu];
        [self addChild:playMenu];
        [self addChild:backMenu];
        [self addChild:personalStatsMenu];
        [self addChild:creditsMenu];
        [self addChild:upgradesMenu];
        [self addChild:shopMenu];
        [self addChild:moreMenu];
        [self addChild:settingsMenu];
        [self addChild:freePointsMenu];
        [self reorderChild:classicMenu z:10];
        [self reorderChild:arcadeMenu z:10];
        [self reorderChild:multiplayerMenu z:10];
        [self reorderChild:challengesMenu z:10];
        [self reorderChild:leaderboardsMenu z:10];
        [self reorderChild:instructionsMenu z:10];
        [self reorderChild:playMenu z:10];
        [self reorderChild:backMenu z:10];
        [self reorderChild:creditsMenu z:10];
        [self reorderChild:personalStatsMenu z:10];
        [self reorderChild:upgradesMenu z:10];
        [self reorderChild:shopMenu z:10];
        [self reorderChild:moreMenu z:10];
        [self reorderChild:settingsMenu z:10];
        [self reorderChild:freePointsMenu z:10];
        
        currentMenu = MAIN_MENU;
        
        [self scheduleOnce:@selector(transitionInMain) delay:.9];
        
        //check for unclaimed challenges
        for (int i=1;i<=18;i++)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasCompletedChallenge%d", i]] &&
                ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", i]])
            {
                CCSprite *unclaimed = [CCSprite spriteWithFile:@"mainMenu_challengesUnclaimed.png"];
                [challenges addChild:unclaimed];
                unclaimed.position = ccp(5, 35);
                break;
            }
        }
        
        //update free points to available color if necessary
        if ([AdColony zoneStatusForZone:@"vz6027548cc102427f8d"] == ADCOLONY_ZONE_STATUS_ACTIVE)
            [self AdsAvailable];
        
        //notification center
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(AdsAvailable)
                                                     name:@"Ads Available"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(AdsNotAvailable)
                                                     name:@"Ads Not Available"
                                                   object:nil];
    }
    return self;
}

-(void)AdsAvailable
{
    [freePoints setNormalImage:[CCSprite spriteWithFile:@"mainMenu_freePointsAvailable.png"]];
    [freePoints setSelectedImage:[CCSprite spriteWithFile:@"mainMenu_freePointsAvailableSelected.png"]];
}
-(void)AdsNotAvailable
{
    [freePoints setNormalImage:[CCSprite spriteWithFile:@"mainMenu_freePoints.png"]];
    [freePoints setSelectedImage:[CCSprite spriteWithFile:@"mainMenu_freePointsSelected.png"]];
}

-(void)classic
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[GameLayer sceneForMode:CLASSIC_MODE]]];
}

-(void)arcade
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[GameLayer sceneForMode:ARCADE_MODE]]];
}

-(void)multiplayer
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[MultiplayerLayer scene]]];
}

-(void)challenges
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[ChallengesLayer scene]]];
}

-(void)instructions
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[InstructionsLayer scene]]];
}

-(void)back
{
    if (currentMenu == PLAY_SUBMENU)
    {
        [self transitionOutPlay];
        [self transitionInMain];
    }
    /*else if (currentMenu == STATS_SUBMENU)
    {
        [self transitionOutStats];
        [self transitionInMain];
    }*/
    else if (currentMenu == MORE_SUBMENU)
    {
        [self transitionOutMore];
        [self transitionInMain];
    }
    currentMenu = MAIN_MENU;
}

-(void)play
{
    [self transitionOutMain];
    [self transitionInPlay];
    currentMenu = PLAY_SUBMENU;
}
/*
-(void)stats
{
    [self transitionOutMore];
    [self transitionInStats];
    currentMenu = STATS_SUBMENU;
}*/

-(void)shop
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[ShopLayer scene]]];
}
-(void)more
{
    [self transitionOutMain];
    [self transitionInMore];
    currentMenu = MORE_SUBMENU;
}

-(void)settings
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[SettingsLayer scene]]];
}

-(void)personalStats
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[StatsLayer scene]]];
}
-(void)credits
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[CreditsLayer scene]]];
}
-(void)upgrades
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[UpgradesLayer sceneWithScore:0 combo: 0 forMode:0 fromMainMenu:YES]]];
}

-(void)freePoints
{
    [AdColony playVideoAdForZone:@"vz6027548cc102427f8d"
                    withDelegate:nil
                withV4VCPrePopup:YES
                andV4VCPostPopup:YES];
}

-(void)transitionOutMain
{
    [playMenu stopAllActions];
    [leaderboardsMenu stopAllActions];
    [challengesMenu stopAllActions];
    [shopMenu stopAllActions];
    [freePointsMenu stopAllActions];
    [moreMenu stopAllActions];
    [playMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+165)]];
    [leaderboardsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+105)]];
    [challengesMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+45)]];
    [shopMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-15)]];
    [freePointsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-75)]];
    [moreMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-135)]];
}
-(void)transitionInMain
{
    playMenu.position = ccp(268+550, CENTERY+165);
    leaderboardsMenu.position = ccp(268+770, CENTERY+105);
    challengesMenu.position = ccp(268+990, CENTERY+45);
    shopMenu.position = ccp(268+1210, CENTERY-15);
    freePointsMenu.position = ccp(268+1430, CENTERY-75);
    moreMenu.position = ccp(268+1650, CENTERY-135);
    
    [playMenu runAction:[CCMoveTo actionWithDuration:.55 position:CGPointMake(268, CENTERY+165)]];
    [leaderboardsMenu runAction:[CCMoveTo actionWithDuration:.77 position:CGPointMake(268, CENTERY+105)]];
    [challengesMenu runAction:[CCMoveTo actionWithDuration:.99 position:CGPointMake(268, CENTERY+45)]];
    [shopMenu runAction:[CCMoveTo actionWithDuration:1.21 position:CGPointMake(268, CENTERY-15)]];
    [freePointsMenu runAction:[CCMoveTo actionWithDuration:1.43 position:CGPointMake(268, CENTERY-75)]];
    [moreMenu runAction:[CCMoveTo actionWithDuration:1.65 position:CGPointMake(268, CENTERY-135)]];
}
-(void)transitionOutPlay
{
    [backMenu stopAllActions];
    [classicMenu stopAllActions];
    [arcadeMenu stopAllActions];
    [multiplayerMenu stopAllActions];
    [backMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+165)]];
    [classicMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+105)]];
    [arcadeMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+45)]];
    [multiplayerMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-15)]];

}
-(void)transitionInPlay
{
    backMenu.position = ccp(268+550, CENTERY+165);
    classicMenu.position = ccp(268+770, CENTERY+105);
    arcadeMenu.position = ccp(268+990, CENTERY+45);
    multiplayerMenu.position = ccp(248+1210, CENTERY-15);
    
    [backMenu runAction:[CCMoveTo actionWithDuration:.55 position:CGPointMake(268, CENTERY+165)]];
    [classicMenu runAction:[CCMoveTo actionWithDuration:.77 position:CGPointMake(268, CENTERY+105)]];
    [arcadeMenu runAction:[CCMoveTo actionWithDuration:.99 position:CGPointMake(268, CENTERY+45)]];
    [multiplayerMenu runAction:[CCMoveTo actionWithDuration:1.21 position:CGPointMake(268, CENTERY-15)]];
}
/*
-(void)transitionOutStats
{
    [backMenu stopAllActions];
    [upgradesMenu stopAllActions];
    [personalStatsMenu stopAllActions];
    [backMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+165)]];
    [upgradesMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+105)]];
    [personalStatsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+45)]];
}
-(void)transitionInStats
{
    backMenu.position = ccp(268+550, CENTERY+165);
    upgradesMenu.position = ccp(268+770, CENTERY+105);
    personalStatsMenu.position = ccp(268+990, CENTERY+45);
    
    [backMenu runAction:[CCMoveTo actionWithDuration:.55 position:CGPointMake(268, CENTERY+165)]];
    [upgradesMenu runAction:[CCMoveTo actionWithDuration:.77 position:CGPointMake(268, CENTERY+105)]];
    [personalStatsMenu runAction:[CCMoveTo actionWithDuration:.99 position:CGPointMake(268, CENTERY+45)]];
}*/
-(void)transitionInMore
{
    backMenu.position = ccp(268+550, CENTERY+165);
    upgradesMenu.position = ccp(268+770, CENTERY+105);
    personalStatsMenu.position = ccp(268+990, CENTERY+45);
    instructionsMenu.position = ccp(268+1210, CENTERY-15);
    settingsMenu.position = ccp(268+1430, CENTERY-75);
    creditsMenu.position = ccp(268+1650, CENTERY-135);
    
    [backMenu runAction:[CCMoveTo actionWithDuration:.55 position:CGPointMake(268, CENTERY+165)]];
    [upgradesMenu runAction:[CCMoveTo actionWithDuration:.77 position:CGPointMake(268, CENTERY+105)]];
    [personalStatsMenu runAction:[CCMoveTo actionWithDuration:.99 position:CGPointMake(268, CENTERY+45)]];
    [instructionsMenu runAction:[CCMoveTo actionWithDuration:1.21 position:CGPointMake(268, CENTERY-15)]];
    [settingsMenu runAction:[CCMoveTo actionWithDuration:1.43 position:CGPointMake(268, CENTERY-75)]];
    [creditsMenu runAction:[CCMoveTo actionWithDuration:1.65 position:CGPointMake(268, CENTERY-135)]];
}
-(void)transitionOutMore
{
    [backMenu stopAllActions];
    [upgradesMenu stopAllActions];
    [personalStatsMenu stopAllActions];
    [instructionsMenu stopAllActions];
    [settingsMenu stopAllActions]; 
    [creditsMenu stopAllActions];
    [backMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+165)]];
    [upgradesMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+105)]];
    [personalStatsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY+45)]];
    [instructionsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-15)]];
    [settingsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-75)]];
    [creditsMenu runAction:[CCMoveTo actionWithDuration:.7 position:CGPointMake(268+700, CENTERY-135)]];
}



-(void)update
{
    //------------------PARTICLES----------------
    NSMutableArray *removesPArray = [[NSMutableArray alloc] init];
    for (Particle *tempP in particlesArray)
    {
        if (![tempP update])
        {
            [removesPArray addObject:tempP];
        }
    }
    [particlesArray removeObjectsInArray:removesPArray];
    
    
    
    //---------------creating dots------------
    if ([[NSDate date] timeIntervalSinceDate:self.nextDotCreateDate] >= 0)
    {
        //location
        float x = 10+arc4random()%300;
        //color-----
        int color = arc4random()%1000;
        if (color < 200) color = BLACK;
        else if (color < 400) color = RED;
        else if (color < 600) color = BLUE;
        else if (color < 800) color = GREEN;
        else color = PURPLE;
        
        //speed
        float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
        if (color == GREEN) speed *= 1.75;
        //create dot
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(x, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
        [self reorderChild:tempDot.mySprite z:0];
        
        //set next time for creating dot
        self.nextDotCreateDate = [NSDate dateWithTimeIntervalSinceNow:(1/currentAvgDensity)/2.0 + (1/currentAvgDensity)*(arc4random()%1000)/1000.0];
    }
    
    
    //update dots----------
    NSMutableArray *removesArray = [[NSMutableArray alloc] init];
    for (Dot *d in dotsArray)
    {
        if (![d updateForMainMenu])
        {
            //dot exited screen
            [removesArray addObject:d];
            
            //remove the dot sprites from layer here so [self createDotDeathParticles] can have the sprites to access
            [self removeChild:d.mySprite cleanup:YES];
            for (CCSprite *tempS in d.myTrails)
            {
                [self removeChild:tempS cleanup:YES];
            }
        }
    }
    [dotsArray removeObjectsInArray:removesArray];


    
    
    
    
    
    //------------------DOT EXPLOSIONS----------------
    NSMutableArray *removesExplArray = [[NSMutableArray alloc] init];
    for (CCSprite *tempExplosion in dotExplosionsArray)
    {
        //if low enough alpha, just get rid of this one
        if (tempExplosion.opacity <= DOTEXPLOSION_DECREASE_ALPHA_PER_SECOND/30.0)
        {
            [self removeChild:tempExplosion cleanup:YES];
            [removesExplArray addObject:tempExplosion];
        }
        else
        {
            tempExplosion.opacity -= DOTEXPLOSION_DECREASE_ALPHA_PER_SECOND/30.0;
            tempExplosion.scale += DOTEXPLOSION_INCREASE_SIZE_PER_SECOND/30.0;
        }
    }
    [dotExplosionsArray removeObjectsInArray:removesExplArray];
    

}


-(void)createDustFalling
{
    Particle *temp;
    for (int i=0;i<60;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(arc4random()%57, -3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1.25 forLayer:self];
        [particlesArray addObject:temp];
        [self reorderChild:temp.mySprite z:999];
    }
}
-(void)createDustDots
{
    Particle *temp;
    for (int i=0;i<100;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(320-219+arc4random()%219, -3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1.25 forLayer:self];
        [particlesArray addObject:temp];
        [self reorderChild:temp.mySprite z:999];
    }
}
-(void)createMissedTapParticles:(CGPoint)p
{
    Particle *temp;
    
    for (int i=0;i<25;i++)
    {
        float vx, vy;
        vx = -120+240*(arc4random()%1000)/1000.0;
        vy = -120+240*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:@"particle_redDot.png" atPoint:p withV:CGPointMake(vx, vy) withA:CGPointMake(-vx*1.5, -vy*1.5) withDScale:-.5 withDOpacity:-254 withDuration:.5 forLayer:self];
        [particlesArray addObject:temp];
    }
}
-(CCSprite *)createDotExplosion:(Dot *)d
{
    NSString *fileName;
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_skin"];
    
    switch (d.myColor)
    {
        case BLACK:
            if (skin == SKINS_SQUARE)
                fileName = @"dotExplosion_blackSquare.png";
            else if (skin == SKINS_DIAMOND)
                fileName = @"dotExplosion_blackDiamond.png";
            else if (skin == SKINS_STAR)
                fileName = @"dotExplosion_blackStar.png";
            else
                fileName = @"dotExplosion_black.png";
            break;
        case BLUE:
            if (skin == SKINS_SQUARE)
                fileName = @"dotExplosion_blueSquare.png";
            else if (skin == SKINS_DIAMOND)
                fileName = @"dotExplosion_blueDiamond.png";
            else if (skin == SKINS_STAR)
                fileName = @"dotExplosion_blueStar.png";
            else
                fileName = @"dotExplosion_blue.png";
            break;
        case RED:
            if (skin == SKINS_SQUARE)
                fileName = @"dotExplosion_redSquare.png";
            else if (skin == SKINS_DIAMOND)
                fileName = @"dotExplosion_redDiamond.png";
            else if (skin == SKINS_STAR)
                fileName = @"dotExplosion_redStar.png";
            else
                fileName = @"dotExplosion_red.png";
            break;
        case GREEN:
            if (skin == SKINS_SQUARE)
                fileName = @"dotExplosion_greenSquare.png";
            else if (skin == SKINS_DIAMOND)
                fileName = @"dotExplosion_greenDiamond.png";
            else if (skin == SKINS_STAR)
                fileName = @"dotExplosion_greenStar.png";
            else
                fileName = @"dotExplosion_green.png";
            break;
        case PURPLE:
            if (skin == SKINS_SQUARE)
                fileName = @"dotExplosion_purpleSquare.png";
            else if (skin == SKINS_DIAMOND)
                fileName = @"dotExplosion_purpleDiamond.png";
            else if (skin == SKINS_STAR)
                fileName = @"dotExplosion_purpleStar.png";
            else
                fileName = @"dotExplosion_purple.png";
            break;
        case POWERUP_1:
            fileName = @"dotExplosion_powerup1.png";
            break;
            //case POWERUP_2:
            //    fileName = @"dotExplosion_powerup2.png";
            //    break;
        case POWERUP_3:
            fileName = @"dotExplosion_powerup3.png";
            break;
        default:
            NSLog(@"NO COLOR ERROR");
            return NULL;
            break;
    }
    CCSprite *temp = [CCSprite spriteWithFile:fileName];
    temp.position = d.mySprite.position;
    if (d.myColor != POWERUP_2)
        temp.scale = 0.5; //start at half size so later resolution is still good
    [self addChild:temp];
    return temp;
}
-(void)removeDot:(Dot *)d
{
    //check if purple dot
    if (d.myColor == PURPLE)
    {
        //if in red mode, make it red
        if (d.isInRedMode) [d setMyColor:RED];
    }
    
    //make the dot explosion
    [dotExplosionsArray addObject:[self createDotExplosion:d]];
    
    //kill the dot
    [dotsArray removeObject:d];
    [self removeChild:[d mySprite] cleanup:YES];
    for (CCSprite *tempS in d.myTrails)
    {
        [self removeChild:tempS cleanup:YES];
    }
}



//-------------------------START OF TOUCHES---------------------------------------------------------------
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //check if on a dot
    //first find closest dot
    float closestDistanceSqr = INF;
    Dot *closestDot;
    for (Dot *tempDot in dotsArray)
    {
        double d2 = pow(location.x-tempDot.mySprite.position.x,2)+pow(location.y-tempDot.mySprite.position.y,2);
        if (d2 < closestDistanceSqr)
        {
            closestDistanceSqr = d2;
            closestDot = tempDot;
        }
    }
    if (closestDistanceSqr < INF)
    {
        //found a dot, see if within radius
        if (closestDistanceSqr <= 32*32)
        {
            Dot *newDot;
            //this dot tapped
            switch (closestDot.myColor)
            {
                case BLUE:
                    //create black version of this dot
                    newDot = [[Dot alloc] initForDot:closestDot forColor:BLACK];
                    [dotsArray addObject:newDot];
                    break;
                case PURPLE:
                    //check if not in red mode
                    if (!closestDot.isInRedMode)
                    {
                        //create blue version of this dot
                        newDot = [[Dot alloc] initForDot:closestDot forColor:BLUE];
                        [dotsArray addObject:newDot];
                        break;
                    }
                    //if in red mode, continue to RED
                case RED:
                    [self createMissedTapParticles:closestDot.mySprite.position];
                    break;
                default:
                    break;
                    
            }
            [self removeDot:closestDot];
            
        }
        else
        {
            [self createMissedTapParticles:location];
        }
    }
    else
    {
        [self createMissedTapParticles:location];
    }
}
//-----------------------------------END OF TOUCHES-----------------------------------------------------









//GAME CENTER---------------------

-(void)showLeaderboards
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    
    [leaderboardViewController release];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


@end
