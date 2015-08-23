//
//  GameLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverLayer.h"
#import "MainMenuLayer.h"
#import "InstructionsLayer.h"
#import "AndrewJinLayer.h"
#import "GeorgeQiLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation GameLayer
@synthesize dotsArray, dotExplosionsArray;
@synthesize nextDotCreateDate, powerup3End, startDate, lastUpdateTime, pauseStartDate;
@synthesize gameIsPaused;

+(CCScene *) sceneForMode:(int)m
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [[GameLayer alloc] initForMode:m];
	[scene addChild: layer];
	return scene;
}

-(id)initForMode:(int)m
{
    if (self = [super init])
    {
        gameMode = m;
        
        self.isTouchEnabled = YES;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        NSString *fName, *fSelectedName;
        int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
        if (skin == MENU_SKINS_BLACK) {fName = @"game_menuBlack.png"; fSelectedName = @"game_menuBlackSelected.png";}
        else if (skin == MENU_SKINS_BLUE) {fName = @"game_menuBlue.png"; fSelectedName = @"game_menuBlueSelected.png";}
        else if (skin == MENU_SKINS_GREEN) {fName = @"game_menuGreen.png"; fSelectedName = @"game_menuGreenSelected.png";}
        else {fName = @"game_menu.png"; fSelectedName = @"game_menuSelected.png";}
        topMenuLeft = [CCMenuItemImage itemWithNormalImage:fName selectedImage:fSelectedName];
        topMenuRight = [CCMenuItemImage itemWithNormalImage:fName selectedImage:fSelectedName];
        topMenu = [CCMenu menuWithItems:topMenuLeft, topMenuRight, nil];
        topMenu.position = ccp(160, 2*CENTERY-20+80);
        [topMenu alignItemsHorizontallyWithPadding:100];
        [self addChild:topMenu];
        [self reorderChild:topMenu z:INF+3];
        [topMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(160, 2*CENTERY-20)]];

        
        if (skin == MENU_SKINS_BLACK)
            multiplierMenuSprite = [CCMenuItemImage itemWithNormalImage:@"game_multiplierMenuBlack.png" selectedImage:@"game_multiplierMenuBlackSelected.png"];
        else if (skin == MENU_SKINS_BLUE)
            multiplierMenuSprite = [CCMenuItemImage itemWithNormalImage:@"game_multiplierMenuBlue.png" selectedImage:@"game_multiplierMenuBlueSelected.png"];
        else if (skin == MENU_SKINS_GREEN)
            multiplierMenuSprite = [CCMenuItemImage itemWithNormalImage:@"game_multiplierMenuGreen.png" selectedImage:@"game_multiplierMenuGreenSelected.png"];
        else
            multiplierMenuSprite = [CCMenuItemImage itemWithNormalImage:@"game_multiplierMenu.png" selectedImage:@"game_multiplierMenuSelected.png"];
        multiplierMenu = [CCMenu menuWithItems:multiplierMenuSprite, nil];
        multiplierMenu.position = ccp(160, 20-80);
        [self addChild:multiplierMenu];
        [self reorderChild:multiplierMenu z:INF+3];
        [multiplierMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(160, 20)]];
        
        multiplierBar = [CCSprite spriteWithFile:@"game_multiplierBarBlack.png"];
        multiplierBar.anchorPoint = CGPointMake(0, .5);
        multiplierBar.position = ccp(0, 2.5-80);
        multiplierBar.scaleX = 1/320.0;
        [self addChild:multiplierBar];
        [self reorderChild:multiplierBar z:INF+3];
        [multiplierBar runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(0, 2.5)]];
        
        multiplierLabel = [CCLabelTTF labelWithString:@"Multiplier: x1" fontName:@"Eurostile" fontSize:16];
        multiplierLabel.anchorPoint = CGPointMake(0, .5);
        multiplierLabel.position = ccp(3, 25-80);
        multiplierLabel.color = ccBLACK;
        if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
            multiplierLabel.color = ccWHITE;
        [self addChild:multiplierLabel];
        [self reorderChild:multiplierLabel z:INF+3];
        [multiplierLabel runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(3, 25)]];
        
        comboLabel = [CCLabelTTF labelWithString:@"Combo: 0" fontName:@"Eurostile" fontSize:16];
        comboLabel.anchorPoint = CGPointMake(1, .5);
        comboLabel.position = ccp(317, 25-80);
        comboLabel.color = ccBLACK;
        if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
            comboLabel.color = ccWHITE;
        [self addChild:comboLabel];
        [self reorderChild:comboLabel z:INF+3];
        [comboLabel runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(317, 25)]];
        
        dotsArray = [[NSMutableArray alloc] init];
        dotExplosionsArray = [[NSMutableArray alloc] init];
        particlesArray = [[NSMutableArray alloc] init];
        
        currentAvgDensity = INITIAL_AVG_DENSITY;
        currentAvgBaseSpeed = INITIAL_AVG_BASE_SPEED*(1-[self barVal:2]/700.0);
        self.nextDotCreateDate = [NSDate date];
        elapsedTime = 0;
        if (gameMode == ARCADE_MODE) currentAvgDensity *= 1.3;
        
        //score
        score = 0;
        CCLabelTTF *textLabel, *numberLabel;
        textLabel = [CCLabelTTF labelWithString:@"Score" fontName:@"Eurostile" fontSize:13];
        textLabel.color = ccBLACK;
        numberLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Eurostile" fontSize:24];
        numberLabel.color = ccBLACK;
        if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
        {
            textLabel.color = ccWHITE;
            numberLabel.color = ccWHITE;
        }
        scoreTextLabel = [CCMenuItemLabel itemWithLabel:textLabel];
        scoreNumberLabel = [CCMenuItemLabel itemWithLabel:numberLabel];
        scoreMenu = [CCMenu menuWithItems:scoreTextLabel, scoreNumberLabel, nil];
        [scoreMenu alignItemsHorizontallyWithPadding:10];
        scoreMenu.position = ccp(50, CENTERY*2-19+80);
        [self addChild:scoreMenu];
        [self reorderChild:scoreMenu z:INF+4];
        [scoreMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(50, CENTERY*2-19)]];
        
        //lives/time
        if (gameMode == CLASSIC_MODE || gameMode == GEORGE_QI_MODE)
            lives = START_LIVES*(1+[self barVal:5]/200.0);
        else
            lives = START_TIME*(1+[self barVal:5]/200.0);
        
        CCLabelTTF *textLabel2, *numberLabel2;
        NSString *text = @"Lives";
        if (gameMode == ARCADE_MODE) text = @"Time";
        
        textLabel2 = [CCLabelTTF labelWithString:text fontName:@"Eurostile" fontSize:13];
        textLabel2.color = ccBLACK;
        numberLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)lives] fontName:@"Eurostile" fontSize:24];
        numberLabel2.color = ccBLACK;
        if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
        {
            textLabel2.color = ccWHITE;
            numberLabel2.color = ccWHITE;
        }
        livesTextLabel = [CCMenuItemLabel itemWithLabel:textLabel2];
        livesNumberLabel = [CCMenuItemLabel itemWithLabel:numberLabel2];
        livesMenu = [CCMenu menuWithItems:livesTextLabel, livesNumberLabel, nil];
        [livesMenu alignItemsHorizontallyWithPadding:10];
        livesMenu.position = ccp(270, CENTERY*2-19+80);
        [self addChild:livesMenu];
        [self reorderChild:livesMenu z:INF+4];
        [livesMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(270, CENTERY*2-19)]];
        
        //pause menu
        
        if (skin == MENU_SKINS_BLACK)
            pause = [CCMenuItemImage itemWithNormalImage:@"game_pauseBlack.png" selectedImage:@"game_pauseBlackSelected.png" target:self selector:@selector(pauseGame)];
        else if (skin == MENU_SKINS_BLUE)
            pause = [CCMenuItemImage itemWithNormalImage:@"game_pauseBlue.png" selectedImage:@"game_pauseBlueSelected.png" target:self selector:@selector(pauseGame)];
        else if (skin == MENU_SKINS_GREEN)
            pause = [CCMenuItemImage itemWithNormalImage:@"game_pauseGreen.png" selectedImage:@"game_pauseGreenSelected.png" target:self selector:@selector(pauseGame)];
        else
            pause = [CCMenuItemImage itemWithNormalImage:@"game_pause.png" selectedImage:@"game_pauseSelected.png" target:self selector:@selector(pauseGame)];
        pauseMenu = [CCMenu menuWithItems:pause, nil];
        pauseMenu.position = ccp(160, 2*CENTERY-20+((gameMode==ANDREW_JIN_MODE || gameMode == GEORGE_QI_MODE)?80:960));
        [self addChild:pauseMenu];
        [self reorderChild:pauseMenu z:INF+5];
        [pauseMenu runAction:[CCMoveTo actionWithDuration:((gameMode==ANDREW_JIN_MODE || gameMode == GEORGE_QI_MODE)?.6:4.5) position:CGPointMake(160, 2*CENTERY-20)]];
        
        //ANDREW JIN MODE leave now
        if (gameMode == ANDREW_JIN_MODE) return self;
        
        //GEORGE QI MODE start game, call update, leave
        if (gameMode == GEORGE_QI_MODE)
        {
            [self startGame];
            [self schedule:@selector(update) interval:1/30.0000];
            multiplier = 1;
            consecutiveTaps = 0;
            return self;
        }
        
        //items
        speedMultiplier_item = 1;
        [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"purpleItemActive"];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"] > 0)
        {
            item1 = [CCMenuItemImage itemWithNormalImage:@"game_item1.png" selectedImage:@"game_item1Selected.png" target:self selector:@selector(useItem1)];
            item1Label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]] fontName:@"Eurostile" fontSize:15];
            item1Label.position = ccp(80,1.5*CENTERY-.75*25);
            item1Label.color = ccBLACK;
            [self addChild:item1Label];
            [self reorderChild:item1Label z:999];
            item1Label.opacity = 0;
            [item1Label runAction:[CCFadeIn actionWithDuration:.5]];
        }
        else item1 = [CCMenuItemImage itemWithNormalImage:@"game_item1Grayed.png" selectedImage:@"game_item1Grayed.png"];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"] > 0)
        {
            item2 = [CCMenuItemImage itemWithNormalImage:@"game_item2.png" selectedImage:@"game_item2Selected.png" target:self selector:@selector(useItem2)];
            item2Label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]] fontName:@"Eurostile" fontSize:15];
            item2Label.position = ccp(160,1.5*CENTERY-.75*25);
            item2Label.color = ccBLACK;
            [self addChild:item2Label];
            [self reorderChild:item2Label z:999];
            item2Label.opacity = 0;
            [item2Label runAction:[CCFadeIn actionWithDuration:.5]];
        }
        else item2 = [CCMenuItemImage itemWithNormalImage:@"game_item2Grayed.png" selectedImage:@"game_item2Grayed.png"];

        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"] > 0)
        {
            item3 = [CCMenuItemImage itemWithNormalImage:@"game_item3.png" selectedImage:@"game_item3Selected.png" target:self selector:@selector(useItem3)];
            item3Label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]] fontName:@"Eurostile" fontSize:15];
            item3Label.position = ccp(240,1.5*CENTERY-.75*25);
            item3Label.color = ccBLACK;
            [self addChild:item3Label];
            [self reorderChild:item3Label z:999];
            item3Label.opacity = 0;
            [item3Label runAction:[CCFadeIn actionWithDuration:.5]];
        }
        else item3 = [CCMenuItemImage itemWithNormalImage:@"game_item3Grayed.png" selectedImage:@"game_item3Grayed.png"];

        item1.scale = .75;
        item2.scale = .75;
        item3.scale = .75;
        item1Menu = [CCMenu menuWithItems:item1, nil];
        item2Menu = [CCMenu menuWithItems:item2, nil];
        item3Menu = [CCMenu menuWithItems:item3, nil];
        [self addChild:item1Menu];
        [self addChild:item2Menu];
        [self addChild:item3Menu];
        item1Menu.opacity = 0;
        item2Menu.opacity = 0;
        item3Menu.opacity = 0;
        [item1Menu runAction:[CCFadeIn actionWithDuration:.5]];
        [item2Menu runAction:[CCFadeIn actionWithDuration:.5]];
        [item3Menu runAction:[CCFadeIn actionWithDuration:.5]];
        item1Menu.position = ccp(80, 1.5*CENTERY);
        item2Menu.position = ccp(160, 1.5*CENTERY);
        item3Menu.position = ccp(240, 1.5*CENTERY);
        
        itemLabel = [CCLabelTTF labelWithString:@"Tap to use an item." fontName:@"Eurostile" fontSize:16];
        [self addChild:itemLabel];
        itemLabel.color = ccBLACK;
        itemLabel.opacity = 0;
        [itemLabel runAction:[CCFadeIn actionWithDuration:.5]];
        itemLabel.position = ccp(160, 1.5*CENTERY+60);
        
        
        //wait/countdown---
        wait = [CCMenuItemImage itemWithNormalImage:@"game_goToInstruction.png" selectedImage:@"game_goToInstructionSelected.png" target:self selector:@selector(goToInstructions)];
        waitMenu = [CCMenu menuWithItems:wait, nil];
        waitMenu.position = ccp(160, 100-(2*CENTERY));
        [self addChild:waitMenu];
        [waitMenu runAction:[CCMoveTo actionWithDuration:1.6 position:CGPointMake(160, 100)]];
        
        countdown3 = [CCLabelTTF labelWithString:@"3" fontName:@"Eurostile" fontSize:72];
        countdown2 = [CCLabelTTF labelWithString:@"2" fontName:@"Eurostile" fontSize:72];
        countdown1 = [CCLabelTTF labelWithString:@"1" fontName:@"Eurostile" fontSize:72];
        countdownGo = [CCLabelTTF labelWithString:@"GO!" fontName:@"Eurostile" fontSize:72];
        countdown3.position = ccp(160-1280, CENTERY+10);
        countdown2.position = ccp(160-1280*11/6.0, CENTERY+10);
        countdown1.position = ccp(160-1280*16/6.0, CENTERY+10);
        countdownGo.position = ccp(160-1280*21/6.0, CENTERY+10);
        countdown3.color = ccBLACK;
        countdown2.color = ccBLACK;
        countdown1.color = ccBLACK;
        countdownGo.color = ccBLACK;
        [self addChild:countdown3];
        [self addChild:countdown2];
        [self addChild:countdown1];
        [self addChild:countdownGo];
        [countdown3 runAction:[CCMoveTo actionWithDuration:1.2 position:CGPointMake(160, CENTERY+10)]];
        [countdown2 runAction:[CCMoveTo actionWithDuration:2.2 position:CGPointMake(160, CENTERY+10)]];
        [countdown1 runAction:[CCMoveTo actionWithDuration:3.2 position:CGPointMake(160, CENTERY+10)]];
        [countdownGo runAction:[CCMoveTo actionWithDuration:4.2 position:CGPointMake(160, CENTERY+10)]];
        [self scheduleOnce:@selector(countdown3Leave) delay:2];
        [self scheduleOnce:@selector(countdown2Leave) delay:3];
        [self scheduleOnce:@selector(countdown1Leave) delay:4];
        [self scheduleOnce:@selector(countdownGoLeave) delay:4.5];
        gameHasStarted = NO;
        [self scheduleOnce:@selector(startGame) delay:4.5];
        
        [self schedule:@selector(update) interval:1/30.0];
        [self schedule:@selector(updatePowerupFades) interval:1/30.0];
        
        
        multiplier = 1;
        consecutiveTaps = 0;
    }
    return self;
}

-(void)countdown3Leave
{
    //[countdown3 runAction:[CCMoveTo actionWithDuration:.1 position:CGPointMake(160+320, CENTERY)]];
    [countdown3 runAction:[CCFadeOut actionWithDuration:.2]];
}
-(void)countdown2Leave
{
    //[countdown2 runAction:[CCMoveTo actionWithDuration:.1 position:CGPointMake(160+320, CENTERY)]];
    [countdown2 runAction:[CCFadeOut actionWithDuration:.2]];
}
-(void)countdown1Leave
{
    //[countdown1 runAction:[CCMoveTo actionWithDuration:.1 position:CGPointMake(160+320, CENTERY)]];
    [countdown1 runAction:[CCFadeOut actionWithDuration:.2]];
}
-(void)countdownGoLeave
{
    //[countdownGo runAction:[CCMoveTo actionWithDuration:.1 position:CGPointMake(160+320, CENTERY)]];
    [countdownGo runAction:[CCFadeOut actionWithDuration:.2]];
    
}
-(void)removeCountdowns
{
    [self removeChild:countdown3 cleanup:YES];
    [self removeChild:countdown2 cleanup:YES];
    [self removeChild:countdown1 cleanup:YES];
    [self removeChild:countdownGo cleanup:YES];
}
-(void)removeWaitMenu
{
    [self removeChild:waitMenu cleanup:YES];
}
-(void)removeItemObjects
{
    [self removeChild:item1Menu cleanup:YES];
    [self removeChild:item2Menu cleanup:YES];
    [self removeChild:item3Menu cleanup:YES];
    [self removeChild:itemLabel cleanup:YES];
    if ([[self children] containsObject:item1Label]) [self removeChild:item1Label cleanup:YES];
    if ([[self children] containsObject:item2Label]) [self removeChild:item2Label cleanup:YES];
    if ([[self children] containsObject:item3Label]) [self removeChild:item3Label cleanup:YES];
}
-(void)startGame
{
    //fade out item stuff if necessary
    if (!hasRemovedItemImages)
    {
        [item1Menu setEnabled:NO];
        [item2Menu setEnabled:NO];
        [item3Menu setEnabled:NO];
        [item1Menu runAction:[CCFadeOut actionWithDuration:.5]];
        [item2Menu runAction:[CCFadeOut actionWithDuration:.5]];
        [item3Menu runAction:[CCFadeOut actionWithDuration:.5]];
        [itemLabel runAction:[CCFadeOut actionWithDuration:.5]];
        if ([[self children] containsObject:item1Label]) [item1Label runAction:[CCFadeOut actionWithDuration:.5]];
        if ([[self children] containsObject:item2Label]) [item2Label runAction:[CCFadeOut actionWithDuration:.5]];
        if ([[self children] containsObject:item3Label]) [item3Label runAction:[CCFadeOut actionWithDuration:.5]];
    
        [self scheduleOnce:@selector(removeItemObjects) delay:.5];
    }
    
    gameHasStarted = YES;
    [self scheduleOnce:@selector(removeCountdowns) delay:.5];
    [waitMenu runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 100-.5*1.25*CENTERY)]];
    [self scheduleOnce:@selector(removeWaitMenu) delay:.5];
    
    
    //arcade mode formations
    if (gameMode == ARCADE_MODE)
    {
        [self schedule:@selector(createFormation) interval:10+(arc4random()%4001)/1000.0];
    }
    
    //times
    self.startDate = [NSDate date];
    self.lastUpdateTime = [NSDate date];
    
}
-(void)goToInstructions
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[InstructionsLayer scene]]];
}


-(void)useItem1 //dot debilitator
{
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]-1 forKey:@"shop_item1"];
    item1Label.string = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]];
    
    speedMultiplier_item = .95;
    
    //fade out item stuff
    hasRemovedItemImages = YES;
    [item1Menu setEnabled:NO];
    [item2Menu setEnabled:NO];
    [item3Menu setEnabled:NO];
    [item1Menu runAction:[CCFadeOut actionWithDuration:2]];
    [item2Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [item3Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [itemLabel runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item1Label]) [item1Label runAction:[CCFadeOut actionWithDuration:2]];
    if ([[self children] containsObject:item2Label]) [item2Label runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item3Label]) [item3Label runAction:[CCFadeOut actionWithDuration:.5]];
    
    [self scheduleOnce:@selector(removeItemObjects) delay:2];
}
-(void)useItem2 //purple persister
{
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]-1 forKey:@"shop_item2"];
    item2Label.string = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]];
    
    [[NSUserDefaults standardUserDefaults] setFloat:1.2 forKey:@"purpleItemActive"];
    
    //fade out item stuff
    hasRemovedItemImages = YES;
    [item1Menu setEnabled:NO];
    [item2Menu setEnabled:NO];
    [item3Menu setEnabled:NO];
    [item1Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [item2Menu runAction:[CCFadeOut actionWithDuration:2]];
    [item3Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [itemLabel runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item1Label]) [item1Label runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item2Label]) [item2Label runAction:[CCFadeOut actionWithDuration:2]];
    if ([[self children] containsObject:item3Label]) [item3Label runAction:[CCFadeOut actionWithDuration:.5]];
    
    [self scheduleOnce:@selector(removeItemObjects) delay:2];
}
-(void)useItem3 //combo catalyst
{
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]-1 forKey:@"shop_item3"];
    item3Label.string = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]];
    
    for (int i=0;i<30;i++) {[self addConsecutiveTap];}
    
    //fade out item stuff
    hasRemovedItemImages = YES;
    [item1Menu setEnabled:NO];
    [item2Menu setEnabled:NO];
    [item3Menu setEnabled:NO];
    [item1Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [item2Menu runAction:[CCFadeOut actionWithDuration:.5]];
    [item3Menu runAction:[CCFadeOut actionWithDuration:2]];
    [itemLabel runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item1Label]) [item1Label runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item2Label]) [item2Label runAction:[CCFadeOut actionWithDuration:.5]];
    if ([[self children] containsObject:item3Label]) [item3Label runAction:[CCFadeOut actionWithDuration:2]];
    
    [self scheduleOnce:@selector(removeItemObjects) delay:2];
}



-(void)update
{
    //ANDREW JIN
    if (gameMode == ANDREW_JIN_MODE) return;
    
    if (!gameHasStarted) return;
    
    if (gameIsPaused) return;
    
    //elapsedTime += 1/30.0000;
    elapsedTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
    if (gameMode == ARCADE_MODE)
    {
        lives -= [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
        self.lastUpdateTime = [NSDate date];
    }
    //NSLog(@"elapsed Time: %f", elapsedTime);
    
    //if (gameMode == ARCADE_MODE) [self removeLife];
    if (gameMode == ARCADE_MODE)
    {
        CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)lives] fontName:@"Eurostile" fontSize:24];
        
        int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
        tempLabel.color = ccBLACK;
        if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
            tempLabel.color = ccWHITE;
        //if < 10 lives, increasingly closer to red
        if (lives <= 10 && lives > 0)
        {
            tempLabel.color = ccc3(275-lives*25, 0, 0);
            if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
                tempLabel.color = ccc3(275-lives*25, 255, 255);
        }
        
        
        [(CCMenuItemLabel *)[[livesMenu children] objectAtIndex:1] setLabel:tempLabel];
        
        
        //check if no lives left
        if (lives < 1 && !gameIsOver)
        {
            //game over
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:[GameOverLayer sceneWithScore:score combo:maxCombo forMode:gameMode withAnimations:YES] withColor:ccWHITE]];
            gameIsOver = YES;
        }
    }
    
    //-------------DOTS-------------
    
    //update avg density and avg speed
    if (gameMode == GEORGE_QI_MODE)
    {
        //george mode speed/density increases
        if (currentAvgBaseSpeed < MAX_SPEED) //cutoff at max speed
            currentAvgBaseSpeed += .2*((SPEED_INCREASE_PER_SECOND/30.0)*(1-[self barVal:2]/700.0))*
                                                                                    ((elapsedTime >= DIFF_INC_PLATEAU_TIME)
                                                                                                ?DIFF_INC_MIN_MULTIPLIER
                                                                                                 :(1-(1-DIFF_INC_MIN_MULTIPLIER)*elapsedTime/DIFF_INC_PLATEAU_TIME));
        
        currentAvgDensity += .2*(DENSITY_INCREASE_PER_SECOND/30.0)*((elapsedTime >= DIFF_INC_PLATEAU_TIME)
                                                                 ?DIFF_INC_MIN_MULTIPLIER
                                                                 :(1-(1-DIFF_INC_MIN_MULTIPLIER)*elapsedTime/DIFF_INC_PLATEAU_TIME));
    }
    else
    {
        if (currentAvgBaseSpeed < MAX_SPEED) //cutoff at max speed
        currentAvgBaseSpeed += ((SPEED_INCREASE_PER_SECOND/30.0)*(1-[self barVal:2]/700.0))*((elapsedTime >= DIFF_INC_PLATEAU_TIME)
                                                                                         ?DIFF_INC_MIN_MULTIPLIER
                                                                                         :(1-(1-DIFF_INC_MIN_MULTIPLIER)*elapsedTime/DIFF_INC_PLATEAU_TIME));
        currentAvgDensity += (DENSITY_INCREASE_PER_SECOND/30.0)*((elapsedTime >= DIFF_INC_PLATEAU_TIME)
                                                             ?DIFF_INC_MIN_MULTIPLIER
                                                             :(1-(1-DIFF_INC_MIN_MULTIPLIER)*elapsedTime/DIFF_INC_PLATEAU_TIME));
    }
    
    //creating dots--------
    if ([[NSDate date] timeIntervalSinceDate:self.nextDotCreateDate] >= 0)
    {
        //location
        float x = 10+arc4random()%300;
        //color-----
        int color = arc4random()%1000;
        if (gameMode == CLASSIC_MODE || gameMode == GEORGE_QI_MODE)
        {
            //CLASSIC MODE color
            if (elapsedTime <= 40) //early game
            {
                if (color < 810-5.5*elapsedTime) color = BLACK;
                else if (color < 800) color = BLUE;
                else if (color < 900) color = GREEN;
                else color = RED;
            }
            else if (elapsedTime <= 100) //mid game
            {
                if (color < 580) color = BLACK;
                else if (color < 830-1.6*elapsedTime) color = BLUE;
                else if (color < 780) color = PURPLE;
                else if (color < 880) color = GREEN;
                else color = RED;
            }
            else //late game
            {
                if (color < 450) color = BLACK;
                else if (color < 825)
                {
                    int which = arc4random()%1000;
                    if (which < 400) color = BLUE;
                    else if (which < 550) color = PURPLE;
                    else color = GREEN;
                }
                else color = RED;
            }
        }
        else
        {
            //ARCADE MODE color
            if (elapsedTime <= 40) //early game
            {
                if (color < 550) color = BLACK;
                else if (color < 810-1.6*elapsedTime) color = BLUE;
                else if (color < 800) color = PURPLE;
                else if (color < 900) color = GREEN;
                else color = RED;
            }
            else //late game
            {
                if (color < 400) color = BLACK;
                else if (color < 850)
                {
                    int which = arc4random()%1000;
                    if (which < 400) color = BLUE;
                    else if (which < 600) color = PURPLE;
                    else color = GREEN;
                }
                else color = RED;
            }
            
            //4.5% chance of powerup (arcade), 3.5% late game
            if (arc4random()%1000 < ((elapsedTime>40)?35:45))
            {
                int which = arc4random()%1000;
                if (which < 250) color = POWERUP_1;
                else if (which < 750) color = POWERUP_2;
                else color = POWERUP_3;
            }
        }

        //speed
        float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
        if (color == GREEN) speed *= 1.75;
        if (color == PURPLE) speed *= .6;
        if (color == POWERUP_1 || color == POWERUP_2 || color == POWERUP_3) speed *= .65;
        //create dot
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(x, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
        
        //set next time for creating dot
        self.nextDotCreateDate = [NSDate dateWithTimeIntervalSinceNow:(1/currentAvgDensity)/2.0 + (1/currentAvgDensity)*(arc4random()%1000)/1000.0];
        
                                  
    }
    
    
    //update dots----------
    NSMutableArray *removesArray = [[NSMutableArray alloc] init];
    for (Dot *d in dotsArray)
    {
        if (![d update])
        {
            //dot exited screen
            if (d.myColor != RED)
            {
                //only death particles and remove life for non-red
                [self createDotDeathParticles:d];
                if (gameMode == CLASSIC_MODE || gameMode == GEORGE_QI_MODE)
                    [self removeLife];
                else if (gameMode == ARCADE_MODE)
                    [self addScore:-1];
                [self resetMultiplier];
            }
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
    
    //------MULTIPLIERS------
    /*if (multiplier == 1 && consecutiveTaps >= THRESHOLD_2X)
    {
        //change to 2x
        multiplier = 2;
        [self reorderChild:background z:-2];
        [self reorderChild:background2x z:-1];
        [self createMultiplierParticlesGreen];
    }
    else if (multiplier == 2 && consecutiveTaps >= THRESHOLD_3X)
    {
        //change to 3x
        multiplier = 3;
        [self reorderChild:background2x z:-2];
        [self reorderChild:background3x z:-1];
        [self createMultiplierParticlesBlue];
    }
    else if (multiplier == 3 && consecutiveTaps >= THRESHOLD_4X)
    {
        //change to 4x
        multiplier = 4;
        [self reorderChild:background3x z:-2];
        [self reorderChild:background4x z:-1];
        [self createMultiplierParticlesPurple];
    }*/
    
}

-(void)updatePowerupFades
{
    //check if p3 is active
    if (p3IsActive)
    {
        if (p3OpacityIncreasing) //increase opac
        {
            powerup3_fade25.opacity += 10;
            if (powerup3_fade25.opacity >= 250)
            {
                p3OpacityIncreasing = NO;
            }
        }
        else //decrease opac
        {
            powerup3_fade25.opacity -= 10;
            if (powerup3_fade25.opacity <= 150)
            {
                p3OpacityIncreasing = YES;
            }
        }
        
        //check for end of powerup
        if ([[NSDate date] timeIntervalSinceDate:self.powerup3End] >= 0)
        {
            [self removeChild:powerup3_fade25 cleanup:YES];
            p3IsActive = NO;
        }
    }
}



//-------------------------START OF TOUCHES---------------------------------------------------------------
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (gameIsOver) return;
    
    if (!gameHasStarted) return;
    
    if (gameIsPaused) return; 
    
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.y > 2*CENTERY-40 || location.y < 40) return; //must be in visible area for dots
    
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
        if (closestDistanceSqr <= 32*32*(1+[self barVal:4]/80.0))
        {
            Dot *newDot;
            //this dot tapped
            [self addConsecutiveTap];
            switch (closestDot.myColor)
            {
                case BLACK:
                    [self addScore:1];
                    break;
                case BLUE:
                    [self addScore:1];
                    //create black version of this dot
                    newDot = [[Dot alloc] initForDot:closestDot forColor:BLACK];
                    [dotsArray addObject:newDot];
                    break;
                case GREEN:
                    [self addScore:2];
                    break;
                case PURPLE:
                    //check if in red mode
                    if (!closestDot.isInRedMode)
                    {
                        [self addScore:1];
                        //create blue
                        newDot = [[Dot alloc] initForDot:closestDot forColor:BLUE];
                        [dotsArray addObject:newDot];
                        break;
                    }
                    //if in red mode, continue 
                case RED:
                    //check if red dot within the default (un-upgraded) radius
                    if (closestDistanceSqr > 32*32)
                        return;
                    
                    if (gameMode == CLASSIC_MODE || gameMode == GEORGE_QI_MODE)
                        [self removeLife];
                    else [self addScore:-1];
                    [self resetMultiplier];
                    [self createMissedTapParticles:closestDot.mySprite.position];
                    break;
                case POWERUP_1:
                    [self addScore:1];
                    break;
                case POWERUP_2:
                    [self addScore:1];
                    break;
                case POWERUP_3:
                    [self addScore:1];
                    break;
                default:
                    NSLog(@"TAPPED DOT HAS NO COLOR ERROR");
                    break;
                    
            }
            [self removeDot:closestDot];
            
        }
        else
        {
            //missed a tap
            //if (gameMode == CLASSIC_MODE)
            //    [self removeLife];
            //else [self addScore:-1];
            [self resetMultiplier];
            [self createMissedTapParticles:location];
        }
    }
    else
    {
        //no dots in play, missed a tap
        //if (gameMode == CLASSIC_MODE)
        //    [self removeLife];
        //else [self addScore:-1];
        [self resetMultiplier];
        [self createMissedTapParticles:location];
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (gameIsOver) return;
    if (!gameHasStarted) return;
    if (gameIsPaused) return; 
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (location.y > 2*CENTERY-40 || location.y < 40) return; //must be in visible area for dots
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (gameIsOver) return;
    if (!gameHasStarted) return;
    if (gameIsPaused) return; 
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (location.y > 2*CENTERY-40 || location.y < 40) return; //must be in visible area for dots
}
//-----------------------------------END OF TOUCHES-----------------------------------------------------

-(void)addScore:(int)num
{
    if (num >= 0) //gain score
        score+=multiplier*num*(1+[self barVal:1]/200.0)*((p3IsActive)?2:1);
    else if (num < 0) //lose score
        score += num*(1-[self barVal:3]/500.0);
    
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
    
    CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)score] fontName:@"Eurostile" fontSize:24];
    tempLabel.color = ccBLACK;
    if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
        tempLabel.color = ccWHITE;
    [(CCMenuItemLabel *)[[scoreMenu children] objectAtIndex:1] setLabel:tempLabel];
    [scoreMenu alignItemsHorizontallyWithPadding:10];
}
-(void)removeLife
{
    if (gameMode == CLASSIC_MODE || gameMode == GEORGE_QI_MODE)
        lives -= 1-[self barVal:3]/500.0;
    //else lives -= 1/30.0;
    CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)lives] fontName:@"Eurostile" fontSize:24];
    
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
    
    tempLabel.color = ccBLACK;
    if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
        tempLabel.color = ccWHITE;
    //if < 10 lives, increasingly closer to red
    if (lives <= 10 && lives > 0) tempLabel.color = ccc3(275-lives*25, 0, 0);
    
    [(CCMenuItemLabel *)[[livesMenu children] objectAtIndex:1] setLabel:tempLabel];
    [livesMenu alignItemsHorizontallyWithPadding:10];
    
    //check if no lives left
    if (lives < 1 && !gameIsOver)
    {
        //game over
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:[GameOverLayer sceneWithScore:score combo:maxCombo forMode:gameMode withAnimations:YES] withColor:ccWHITE]];
        gameIsOver = YES;
    }
}
-(void)createPowerup1Particles
{
    Particle *temp;
    temp = [[Particle alloc] initWithFileName:@"powerup1_fade25.png" atPoint:CGPointMake(160, CENTERY) withV:CGPointMake(0, 0) withA:CGPointMake(0, 0) withDScale:0 withDOpacity:-255 withDuration:1.5 forLayer:self];
    [particlesArray addObject:temp];
}
-(void)createPowerup2Particles:(Dot *)d
{
    Particle *temp;
    temp = [[Particle alloc] initWithFileName:@"dotExplosion_powerup2.png" atPoint:d.mySprite.position withV:CGPointMake(0, 0) withA:CGPointMake(0, 0) withDScale:0 withDOpacity:-255 withDuration:.75 forLayer:self];
    [particlesArray addObject:temp];
}
-(void)createDotDeathParticles:(Dot *)d
{
    Particle *temp;
    for (int i=0;i<15;i++)
    {
        float vx, vy;
        vx = -120+240*(arc4random()%1000)/1000.0;
        vy = 120+arc4random()%40;
        temp = [[Particle alloc] initWithFileName:@"particle_redDot.png" atPoint:CGPointMake(d.mySprite.position.x-10+arc4random()%21, d.mySprite.position.y-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -240) withDScale:0 withDOpacity:-254 withDuration:.5 forLayer:self];
        [particlesArray addObject:temp];
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
    CGPoint pos = d.mySprite.position;
    
    //check if purple dot
    if (d.myColor == PURPLE)
    {
        //if in red mode, make it red
        if (d.isInRedMode) [d setMyColor:RED];
    }
    
    //make the dot explosion
    if (d.myColor != POWERUP_2) [dotExplosionsArray addObject:[self createDotExplosion:d]];
    else [self createPowerup2Particles:d];
    
    //kill the dot
    [dotsArray removeObject:d];
    [self removeChild:[d mySprite] cleanup:YES];
    for (CCSprite *tempS in d.myTrails)
    {
        [self removeChild:tempS cleanup:YES];
    }
    
    //check if powerup
    if (d.myColor == POWERUP_1)
    {
        //freeze all non-red dots on screen
        for (Dot *tempDot in dotsArray)
        {
            if (tempDot.myColor != RED)
                [tempDot setSpeed:0];
        }
        [self createPowerup1Particles];
    }
    else if (d.myColor == POWERUP_2)
    {
        NSMutableArray *dotRemovesArray = [[NSMutableArray alloc] init];
        //kill all dots within a 150 unit radius
        for (Dot *tempDot in dotsArray)
        {
            float d2 = pow(tempDot.mySprite.position.x-pos.x,2)+pow(tempDot.mySprite.position.y-pos.y,2);
            if (d2 <= 150*150 && ![tempDot isEqual:d])
            {
                [dotRemovesArray addObject:tempDot];
                [self addScore:1];
            }
        }
        
        for (Dot *tempDot in dotRemovesArray)
            if ([dotsArray containsObject:tempDot]) [self removeDot:tempDot];
    }
    else if (d.myColor == POWERUP_3)
    {
        //extend time
        self.powerup3End = [NSDate dateWithTimeIntervalSinceNow:5];
        
        //check if not yet active
        if (!p3IsActive)
        {
            p3IsActive = YES;
            self.powerup3End = [NSDate dateWithTimeIntervalSinceNow:5];
            
            powerup3_fade25 = [CCSprite spriteWithFile:@"powerup3_fade25.png"];
            powerup3_fade25.position = ccp(160, CENTERY);
            [self addChild:powerup3_fade25];
        }
    }
}


-(void)addConsecutiveTap
{
    consecutiveTaps++;
    comboLabel.string = [NSString stringWithFormat:@"Combo: %d", consecutiveTaps];
    
    if (consecutiveTaps > maxCombo) maxCombo = consecutiveTaps;
    
    if (consecutiveTaps < 80)
        multiplierBar.scaleX = consecutiveTaps/80.0;
    else multiplierBar.scaleX = 1;
    
    //check if the 20th, 40th, or 80th consec tap;
    if (consecutiveTaps == 20)
    {
        //2x
        [self removeChild:multiplierBar cleanup:YES];
        multiplierBar = [CCSprite spriteWithFile:@"game_multiplierBarGreen.png"];
        multiplierBar.anchorPoint = CGPointMake(0, .5);
        multiplierBar.scaleX = .25;
        [self addChild:multiplierBar];
        [self reorderChild:multiplierBar z:INF+4];
        
        multiplierLabel.string = @"Multiplier: 2x";
        
        multiplier = 2;
        
        //[self createMultiplierParticlesGreen];
        
        x2 = [CCSprite spriteWithFile:@"game_2x.png"];
        x2.position = ccp(160, CENTERY);
        [self addChild:x2];
        [x2 runAction:[CCFadeOut actionWithDuration:1]];
        [x2 runAction:[CCScaleTo actionWithDuration:1 scale:2]];
        [self scheduleOnce:@selector(removex2) delay:1];
    }
    else if (consecutiveTaps == 40)
    {
        //3x
        [self removeChild:multiplierBar cleanup:YES];
        multiplierBar = [CCSprite spriteWithFile:@"game_multiplierBarBlue.png"];
        multiplierBar.anchorPoint = CGPointMake(0, .5);
        multiplierBar.scaleX = .5;
        [self addChild:multiplierBar];
        [self reorderChild:multiplierBar z:INF+4];
        
        multiplierLabel.string = @"Multiplier: 3x";
        
        multiplier = 3;
        
        //[self createMultiplierParticlesBlue];
        
        x3 = [CCSprite spriteWithFile:@"game_3x.png"];
        x3.position = ccp(160, CENTERY);
        [self addChild:x3];
        [x3 runAction:[CCFadeOut actionWithDuration:1]];
        [x3 runAction:[CCScaleTo actionWithDuration:1 scale:2]];
        [self scheduleOnce:@selector(removex3) delay:1];
    }
    else if (consecutiveTaps == 80)
    {
        //4x
        [self removeChild:multiplierBar cleanup:YES];
        multiplierBar = [CCSprite spriteWithFile:@"game_multiplierBarPurple.png"];
        multiplierBar.anchorPoint = CGPointMake(0, .5);
        multiplierBar.scaleX = 1;
        [self addChild:multiplierBar];
        [self reorderChild:multiplierBar z:INF+4];
        
        multiplierLabel.string = @"Multiplier: 4x";
        
        multiplier = 4;
        
        //[self createMultiplierParticlesPurple];
        
        x4 = [CCSprite spriteWithFile:@"game_4x.png"];
        x4.position = ccp(160, CENTERY);
        [self addChild:x4];
        [x4 runAction:[CCFadeOut actionWithDuration:1]];
        [x4 runAction:[CCScaleTo actionWithDuration:1 scale:2]];
        [self scheduleOnce:@selector(removex4) delay:1];
    }
    
    
    //challenges
    if (consecutiveTaps == 40)
    {
        //apprentice
        NSLog(@"completed challenge 2");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge2"];
    }
    else if (consecutiveTaps == 100)
    {
        //ninja
        NSLog(@"completed challenge 5");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge5"];
    }
    else if (consecutiveTaps == 200)
    {
        //master
        NSLog(@"completed challenge 8");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge8"];
    }
    else if (consecutiveTaps == 500)
    {
        //wtf comboer
        NSLog(@"completed challenge 17");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge17"];
    }
    
    //personal stats
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"bestCombo"] < consecutiveTaps)
        [[NSUserDefaults standardUserDefaults] setInteger:consecutiveTaps forKey:@"bestCombo"];
}


-(void)resetMultiplier
{
    comboLabel.string = @"Combo: 0";
    if (multiplier != 1)
    {        
        [self removeChild:multiplierBar cleanup:YES];
        multiplierBar = [CCSprite spriteWithFile:@"game_multiplierBarBlack.png"];
        multiplierBar.anchorPoint = CGPointMake(0, .5);
        [self addChild:multiplierBar];
        [self reorderChild:multiplierBar z:INF+4];
        
        comboBreaker = [CCSprite spriteWithFile:@"game_comboBreaker.png"];
        comboBreaker.position = ccp(160, CENTERY);
        comboBreaker.scale = 2;
        [self addChild:comboBreaker];
        [comboBreaker runAction:[CCFadeOut actionWithDuration:1]];
        [comboBreaker runAction:[CCScaleTo actionWithDuration:.2 scale:1]];
        [self scheduleOnce:@selector(removeComboBreaker) delay:1];
    }
    multiplierBar.scaleX = 1/320.0;
    
    multiplierLabel.string = @"Multiplier: 1x";
    multiplier = 1;
    consecutiveTaps = 0;
    
}
-(void)createMultiplierParticlesGreen
{
    Particle *temp;
    for (int i=0;i<30;i++)
    {
        float vx, vy;
        vx = -480+960*(arc4random()%1000)/1000.0;
        vy = -480+960*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:@"particle_greenStar.png" atPoint:CGPointMake(160-10+arc4random()%21, CENTERY-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(-vx*1.5, -vy*1.5) withDScale:1 withDOpacity:-254 withDuration:1 forLayer:self];
        temp.mySprite.scale = .5; //start at half to ensure good resolution later
        [particlesArray addObject:temp];
    }
}
-(void)createMultiplierParticlesBlue
{
    Particle *temp;
    for (int i=0;i<30;i++)
    {
        float vx, vy;
        vx = -480+960*(arc4random()%1000)/1000.0;
        vy = -480+960*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:@"particle_blueStar.png" atPoint:CGPointMake(160-10+arc4random()%21, CENTERY-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(-vx*1.5, -vy*1.5) withDScale:1 withDOpacity:-254 withDuration:1 forLayer:self];
        temp.mySprite.scale = .5; //start at half to ensure good resolution later
        [particlesArray addObject:temp];
    }
}
-(void)createMultiplierParticlesPurple
{
    Particle *temp;
    for (int i=0;i<30;i++)
    {
        float vx, vy;
        vx = -480+960*(arc4random()%1000)/1000.0;
        vy = -480+960*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:@"particle_purpleStar.png" atPoint:CGPointMake(160-10+arc4random()%21, CENTERY-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(-vx*1.5, -vy*1.5) withDScale:1 withDOpacity:-254 withDuration:1 forLayer:self];
        temp.mySprite.scale = .5; //start at half to ensure good resolution later
        [particlesArray addObject:temp];
    }
}
-(void)removex2
{
    if ([[self children] containsObject:x2]) [self removeChild:x2 cleanup:YES];
}
-(void)removex3
{
    if ([[self children] containsObject:x3]) [self removeChild:x3 cleanup:YES];
}
-(void)removex4
{
    if ([[self children] containsObject:x4]) [self removeChild:x4 cleanup:YES];
}
-(void)removeComboBreaker
{
    if ([[self children] containsObject:comboBreaker]) [self removeChild:comboBreaker cleanup:YES];
}


//-------------------ARCADE STUFF----------------------
-(void)createFormation
{
    int which = arc4random()%7000;
    if (which < 1000) [self createBlast];
    else if (which < 2000) [self createRainbowBlast];
    else if (which < 3000) [self createStairs];
    else if (which < 4000) [self createRainbowStairs];
    else if (which < 5000) [self createBox];
    else if (which < 6000) [self createLine];
    else [self createRainbowLine];
}

-(void)createBlast
{
    int color = arc4random()%1000;
    if (color < 400) color = BLACK;
    else if (color < 550) color = RED;
    else if (color < 750) color = GREEN;
    else if (color < 950) color = BLUE;
    else color = PURPLE;
    
    int numDots = 0;
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    if (color == GREEN) speed *= 1.75;
    
    switch (color)
    {
        case RED:
            numDots = 8+arc4random()%2;
            break;
        case BLACK:
            numDots = 8+arc4random()%2;
            break;
        case BLUE:
            numDots = 6+arc4random()%2;
            break;
        case PURPLE:
            numDots = 4+arc4random()%1;
            break;
        case GREEN:
            numDots = 5+arc4random()%2;
            break;
        default:
            break;
            
    }
    
    //create dot
    for (int i=1;i<=numDots;i++)
    {
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(10+300*i/numDots, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}

-(void)createRainbowBlast
{
    int color = arc4random()%1000;
    if (color < 450) color = BLACK;
    else if (color < 700) color = RED;
    else if (color < 900) color = BLUE;
    else color = PURPLE;
    
    int numDots = 6+arc4random()%4;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    
    //create dot
    for (int i=1;i<=numDots;i++)
    {
        int color = arc4random()%1000;
        if (color < 450) color = BLACK;
        else if (color < 700) color = RED;
        else if (color < 900) color = BLUE;
        else color = PURPLE;
        
        
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(10+300*i/numDots, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}

-(void)createStairs
{
    int color = arc4random()%1000;
    if (color < 500) color = BLACK;
    else if (color < 700) color = GREEN;
    else if (color < 950) color = BLUE;
    else color = PURPLE;
    int numDots = 6+arc4random()%6;
    if (color == PURPLE) numDots--;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    if (color == GREEN) speed *= 1.75;
    
    for (int i=1;i<=numDots;i++)
    {
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(10+300*i/numDots, 2*CENTERY+20+30*i) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}
-(void)createRainbowStairs
{
    int color = arc4random()%1000;
    if (color < 700) color = BLACK;
    else if (color < 900) color = BLUE;
    else color = PURPLE;
    
    int numDots = 6+arc4random()%6;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    
    for (int i=1;i<=numDots;i++)
    {
        int color = arc4random()%1000;
        if (color < 700) color = BLACK;
        else if (color < 900) color = BLUE;
        else color = PURPLE;
        
        
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(10+300*i/numDots, 2*CENTERY+20+30*i) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}

-(void)createBox
{
    int color = arc4random()%1000;
    if (color < 600) color = BLACK;
    else if (color < 800) color = GREEN;
    else color = BLUE;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    if (color == GREEN) speed *= 1.75;
    
    int centerx = 100+arc4random()%120;
    Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx-40, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx+40, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx-40, 2*CENTERY+20+40) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx-40, 2*CENTERY+20+80) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx, 2*CENTERY+20+80) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx+40, 2*CENTERY+20+80) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
    tempDot = [[Dot alloc] initAtPoint:CGPointMake(centerx+40, 2*CENTERY+20+40) withColor:color withSpeed:speed forLayer:self];
    [dotsArray addObject:tempDot];
}

-(void)createLine
{
    int color = arc4random()%1000;
    if (color < 500) color = BLACK;
    else if (color < 700) color = GREEN;
    else if (color < 950) color = BLUE;
    else color = PURPLE;
    int numDots = 6+arc4random()%6;
    if (color == BLUE) numDots-=2;
    if (color == PURPLE) numDots-=4;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    if (color == GREEN) speed *= 1.75;
    
    int spacing = 25+arc4random()%20;
    int xcoordinate = 10+arc4random()%300;
    
    for (int i=1;i<=numDots;i++)
    {
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(xcoordinate, 2*CENTERY+20+spacing*i) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}

-(void)createRainbowLine
{
    int color = arc4random()%1000;
    if (color < 700) color = BLACK;
    else if (color < 900) color = BLUE;
    else color = PURPLE;
    
    int numDots = 6+arc4random()%6;
    
    //speed
    float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
    
    int spacing = 25+arc4random()%20;
    int xcoordinate = 10+arc4random()%300;
    
    for (int i=1;i<=numDots;i++)
    {
        int color = arc4random()%1000;
        if (color < 700) color = BLACK;
        else if (color < 900) color = BLUE;
        else color = PURPLE;
        
        
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(xcoordinate, 2*CENTERY+20+spacing*i) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
    }
}


//-----------PAUSING--------
-(void)pauseGame
{
    self.pauseStartDate = [NSDate date];
    gameIsPaused = YES;
    [pauseMenu setEnabled:NO];
    pauseBackground = [CCSprite spriteWithFile:@"background_game.png"];
    pauseBackground.position = ccp(-160, CENTERY);
    [self addChild:pauseBackground];
    resume = [CCMenuItemImage itemWithNormalImage:@"game_resume.png" selectedImage:@"game_resumeSelected.png" target:self selector:@selector(resume)];
    restart = [CCMenuItemImage itemWithNormalImage:@"game_restart.png" selectedImage:@"game_restartSelected.png" target:self selector:@selector(restart)];
    exit = [CCMenuItemImage itemWithNormalImage:@"game_exit.png" selectedImage:@"game_exitSelected.png" target:self selector:@selector(exit)];
    /*[self addChild:resume];
    [self reorderChild:resume z:INF+2];
    [self addChild:restart];
    [self reorderChild:restart z:INF+2];
    [self addChild:exit];
    [self reorderChild:exit z:INF+2];
    [self schedule:@selector(updatePauseMenu) interval:1/60.0];*/
    pauseScreenMenu = [CCMenu menuWithItems:resume, restart, exit, nil];
    pauseScreenMenu.position = ccp(160-640, CENTERY);
    [pauseScreenMenu alignItemsVerticallyWithPadding:15];
    [self addChild:pauseScreenMenu];
    [self reorderChild:pauseScreenMenu z:INF+2];
    
    [pauseScreenMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    [pauseBackground runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    
}
/*
-(void)updatePauseMenu
{
    numPauseUpdates++;
    if (gameIsPaused)
    { //ENTERING
    if (numPauseUpdates <= .182*60)
        resume.position = ccp(-9778*pow(numPauseUpdates/60.0-.15,2)+170,CENTERY+60);
    else resume.position = ccp(160, CENTERY+60);
    if (numPauseUpdates <= .232*60)
        restart.position = ccp(-9778*pow(numPauseUpdates/60.0-.2,2)+170,CENTERY);
    else restart.position = ccp(160, CENTERY);
    exit.position = ccp(-9778*pow(numPauseUpdates/60.0-.25,2)+170,CENTERY-60);
    if (numPauseUpdates == 17)
    {
        [self unschedule:@selector(updatePauseMenu)];
        [self removeChild:resume cleanup:YES];
        [self removeChild:restart cleanup:YES];
        [self removeChild:exit cleanup:YES];
        resume = [CCMenuItemImage itemWithNormalImage:@"game_resume.png" selectedImage:@"game_resumeSelected.png" target:self selector:@selector(resume)];
        restart = [CCMenuItemImage itemWithNormalImage:@"game_restart.png" selectedImage:@"game_restartSelected.png" target:self selector:@selector(restart)];
        exit = [CCMenuItemImage itemWithNormalImage:@"game_exit.png" selectedImage:@"game_exitSelected.png" target:self selector:@selector(exit)];
        pauseScreenMenu = [CCMenu menuWithItems:resume, restart, exit, nil];
        pauseScreenMenu.position = ccp(160, CENTERY);
        [pauseScreenMenu alignItemsVerticallyWithPadding:20];
        [self addChild:pauseScreenMenu];
        [self reorderChild:pauseScreenMenu z:INF+2];
    }
    }
    else
    { //LEAVING
        pauseBackground.position = ccp(160+8*numPauseUpdates, CENTERY);
        pauseScreenMenu.position = ccp(160+8*numPauseUpdates, CENTERY);
        if (numPauseUpdates == 30)
        {
            [self removeChild:pauseScreenMenu cleanup:YES];
            [self removeChild:pauseBackground cleanup:YES];
            [self unschedule:@selector(updatePauseMenu)];
        }
    }
}*/
-(void)resume
{
    gameIsPaused = NO;
    //[self schedule:@selector(updatePauseMenu) interval:1/60.0];
    [pauseMenu setEnabled:YES];
    [pauseBackground runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+640, CENTERY)]];
    [pauseScreenMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+640, CENTERY)]];

    self.startDate = [NSDate dateWithTimeInterval:[[NSDate date] timeIntervalSinceDate:self.pauseStartDate] sinceDate:self.startDate];
    self.lastUpdateTime = [NSDate date];
        
    CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)lives] fontName:@"Eurostile" fontSize:24];
        
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
    tempLabel.color = ccBLACK;
    if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
        tempLabel.color = ccWHITE;
    //if < 10 lives, increasingly closer to red
    if (lives <= 10 && lives > 0)
    {
        tempLabel.color = ccc3(275-lives*25, 0, 0);
        if (skin == MENU_SKINS_BLUE || skin == MENU_SKINS_BLACK)
            tempLabel.color = ccc3(275-lives*25, 255, 255);
    }
    
}
-(void)removePauseObjects
{
    [self removeChild:pauseBackground cleanup:YES];
    [self removeChild:pauseScreenMenu cleanup:YES];
}
-(void)restart
{
    if (gameMode == ANDREW_JIN_MODE)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[AndrewJinLayer sceneForMode:gameMode] withColor:ccWHITE]];
    }
    else if (gameMode == GEORGE_QI_MODE)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GeorgeQiLayer sceneForMode:gameMode] withColor:ccWHITE]];
    }
    else
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer sceneForMode:gameMode] withColor:ccWHITE]];
}
-(void)exit
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


//---------------NSUSERDEFAULT STUFF--------------
-(int)barVal:(int)n
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"barVal%d", n]];
}
@end
