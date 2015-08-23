//
//  ShopLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 8/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ShopLayer.h"
#import "Particle.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation ShopLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	ShopLayer *layer = [ShopLayer node];
	[scene addChild:layer];
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        self.isTouchEnabled = YES;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        top = [CCSprite spriteWithFile:@"shop_top.png"];
        top.position = ccp(160, 2*CENTERY+9);
        [self addChild:top];
        [self reorderChild:top z:999];
        [top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
        
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-100,2*CENTERY-21);
        [self addChild:backMenu];
        [self reorderChild:backMenu z:1000];
        [backMenu runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(15, 2*CENTERY-21)]];
        
        dotPoints = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]] fontName:@"Eurostile" fontSize:20];
        dotPoints.position = ccp(160, 2*CENTERY-49);
        dotPoints.color = ccBLACK;
        [self addChild:dotPoints];
        [dotPoints setOpacity:0];
        [dotPoints runAction:[CCFadeIn actionWithDuration:.3]];
        
        previous = [CCMenuItemImage itemWithNormalImage:@"instructions_previous.png" selectedImage:@"instructions_previousSelected.png" target:self selector:@selector(previous)];
        next = [CCMenuItemImage itemWithNormalImage:@"instructions_next.png" selectedImage:@"instructions_nextSelected.png" target:self selector:@selector(next)];
        changeMenu = [CCMenu menuWithItems:previous,next,nil];
        [changeMenu alignItemsHorizontallyWithPadding:200];
        changeMenu.position = ccp(160, -12.5);
        [self addChild:changeMenu];
        [self reorderChild:changeMenu z:10];
        [changeMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 12.5)]];
        
        
        circlesArray = [[NSMutableArray alloc] init];
        CCMenuItemImage *circle = [CCMenuItemImage itemWithNormalImage:@"instructions_circleDark.png" selectedImage:@"instructions_circleDark.png"];
        [circlesArray addObject:circle];
        for (int i=1;i<NUM_PAGES_SHOP;i++)
        {
            circle = [CCMenuItemImage itemWithNormalImage:@"instructions_circleLight.png" selectedImage:@"instructions_circleLight.png"];
            [circlesArray addObject:circle];
        }
        circlesMenu = [CCMenu menuWithArray:circlesArray];
        circlesMenu.position = ccp(160, 12.5);
        [circlesMenu alignItemsHorizontallyWithPadding:10];
        [self addChild:circlesMenu];
        [self reorderChild:circlesMenu z:9999];
        
        
        
        
        particlesArray = [[NSMutableArray alloc] init];
        [self schedule:@selector(updateParticles) interval:1/30.0];
        
        
        namesArray = [[NSMutableArray alloc] initWithObjects:
                      @"Dot Debilitator",
                      @"Purple Persister",
                      @"Combo Catalyst", //end pg 1
                      @"Black Menu Skin",
                      @"Blue Menu Skin",
                      @"Green Menu Skin", //end pg 2
                      @"Squares Skin",
                      @"Diamonds Skin",
                      @"Stars Skin", nil];
        descriptionsArray = [[NSMutableArray alloc] initWithObjects:
                             @"Permanently slows all dots by 5%.",
                             @"Makes Purple dots stay purple longer.",
                             @"Instantly gives you a 30 dot combo.", //end pg 1
                             @"The In-Game Menu turns Black!",
                             @"The In-Game Menu turns Blue!",
                             @"The In-Game Menu turns Green!", //end pg 2
                             @"Dots become Sqares!",
                             @"Dots become Diamonds!",
                             @"Dots become Stars!", nil];
        costsArray = [[NSMutableArray alloc] initWithObjects:
                        @"15 Dot Points each\nYou Own: ",
                        @"15 Dot Points each\nYou Own: ",
                        @"15 Dot Points each\nYou Own: ", //end pg 1
                        @"60 Dot Points",
                        @"60 Dot Points",
                        @"60 Dot Points", //end pg 2
                        @"80 Dot Points",
                        @"100 Dot Points",
                        @"120 Dot Points",nil];
        costValues[0] = 15; costValues[1] = 15; costValues[2] = 15;
        costValues[3] = 60; costValues[4] = 60; costValues[5] = 60;
        costValues[6] = 80; costValues[7] = 100; costValues[8] = 120;
        
        
        NSString *fileName = @"shop_background.png";
        if (CENTERY > 240) fileName = @"shop_background-tall.png";
        currentChallenge_bot = [CCSprite spriteWithFile:fileName];
        currentChallenge_mid = [CCSprite spriteWithFile:fileName];
        currentChallenge_top = [CCSprite spriteWithFile:fileName];
        currentChallenge_bot.anchorPoint = CGPointMake(.5, 0);
        currentChallenge_mid.anchorPoint = CGPointMake(.5, 0);
        currentChallenge_top.anchorPoint = CGPointMake(.5, 0);
        [self addChild:currentChallenge_bot];
        [self addChild:currentChallenge_mid];
        [self addChild:currentChallenge_top];
        [currentChallenge_top setVisible:NO];
        [currentChallenge_mid setVisible:NO];
        [currentChallenge_bot setVisible:NO];
        
        currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_item1.png"];
        currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_item1.png"];
        currentIcon_top = [CCSprite spriteWithFile:@"shop_background_item1.png"];
        [self addChild:currentIcon_bot];
        [self addChild:currentIcon_mid];
        [self addChild:currentIcon_top];
        [currentIcon_bot setVisible:NO];
        [currentIcon_mid setVisible:NO];
        [currentIcon_top setVisible:NO];
        
        label_bot = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:14];
        label_mid = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:14];
        label_top = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:14];
        title_bot = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:24];
        title_mid = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:24];
        title_top = [CCLabelTTF labelWithString:@"" fontName:@"Eurostile" fontSize:24];
        label_bot.color = ccBLACK;
        label_mid.color = ccBLACK;
        label_top.color = ccBLACK;
        title_bot.color = ccBLACK;
        title_mid.color = ccBLACK;
        title_top.color = ccBLACK;
        [self addChild:label_bot];
        [self addChild:label_mid];
        [self addChild:label_top];
        [self addChild:title_bot];
        [self addChild:title_mid];
        [self addChild:title_top];
        
        //check for buying---------
        buyTop = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyTop)];
        buyTopMenu = [CCMenu menuWithItems:buyTop, nil];
        [self addChild:buyTopMenu];
        buyTopMenu.opacity = 0;
        buyTopMenu.position = ccp(150,(CENTERY>240)?98.5:84);
        [buyTopMenu setEnabled:NO];
        [self reorderChild:buyTopMenu z:500];
        
        buyMid = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyMid)];
        buyMidMenu = [CCMenu menuWithItems:buyMid, nil];
        [self addChild:buyMidMenu];
        buyMidMenu.opacity = 0;
        buyMidMenu.position = ccp(150,(CENTERY>240)?98.5:84);
        [buyMidMenu setEnabled:NO];
        [self reorderChild:buyMidMenu z:500];

        buyBot = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyBot)];
        buyBotMenu = [CCMenu menuWithItems:buyBot, nil];
        [self addChild:buyBotMenu];
        buyBotMenu.opacity = 0;
        buyBotMenu.position = ccp(150,(CENTERY>240)?98.5:84);
        [buyBotMenu setEnabled:NO];
        [self reorderChild:buyBotMenu z:500];
        
        
        [self scheduleOnce:@selector(showPage1) delay:.3];
        currentPageNum = 1;
        
        [self schedule:@selector(updateDotPointsRed) interval:1/30.0];
        
    }
    return self;
}




-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


-(void)previous
{
    if (currentPageNum <= 1)
        return;
    
    //if stuff falling right now cancel dot explosions, delete particlesArray
    [self unschedule:@selector(createDustDotsTop)];
    [self unschedule:@selector(createDustDotsMid)];
    [self unschedule:@selector(createDustDotsBot)];
    [self unschedule:@selector(enableChange)];
    
    for (Particle *p in particlesArray)
    {
        [self removeChild:p.mySprite cleanup:YES];
    }
    [particlesArray removeAllObjects];
    
    //clear all currently running actions
    [currentChallenge_bot stopAllActions];
    [currentChallenge_mid stopAllActions];
    [currentChallenge_top stopAllActions];
    [currentIcon_bot stopAllActions];
    [currentIcon_mid stopAllActions];
    [currentIcon_top stopAllActions];
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];
    [buyBotMenu stopAllActions];
    [buyMidMenu stopAllActions];
    [buyTopMenu stopAllActions];
    
    [self showPage:currentPageNum-1];
}

-(void)next
{
    if (currentPageNum >= NUM_PAGES_SHOP)
        return;
    
    //if stuff falling right now cancel dot explosions
    [self unschedule:@selector(createDustDotsTop)];
    [self unschedule:@selector(createDustDotsMid)];
    [self unschedule:@selector(createDustDotsBot)];
    [self unschedule:@selector(enableChange)];
    
    for (Particle *p in particlesArray)
    {
        [self removeChild:p.mySprite cleanup:YES];
    }
    [particlesArray removeAllObjects];
    
    //clear all currently running actions
    [currentChallenge_bot stopAllActions];
    [currentChallenge_mid stopAllActions];
    [currentChallenge_top stopAllActions];
    [currentIcon_bot stopAllActions];
    [currentIcon_mid stopAllActions];
    [currentIcon_top stopAllActions];
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];
    [buyBotMenu stopAllActions];
    [buyMidMenu stopAllActions];
    [buyTopMenu stopAllActions];
    
    [self showPage:currentPageNum+1];
}


-(void)updateDotPointsRed
{
    if (dotPoints.color.r > 0)
    {
        [dotPoints setColor:ccc3((dotPoints.color.r<8)?0:dotPoints.color.r-8, 0, 0)];
    }
}
-(void)cantAfford
{
    [dotPoints setColor:ccc3(255, 0, 0)];
}



-(void)updateParticles
{
    NSMutableArray *removesPArray = [[NSMutableArray alloc] init];
    for (Particle *tempP in particlesArray)
    {
        if (![tempP update])
        {
            [removesPArray addObject:tempP];
        }
    }
    [particlesArray removeObjectsInArray:removesPArray];
}

-(void)createDustDotsBot
{
    Particle *temp;
    for (int i=0;i<100;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(10+arc4random()%300, -3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1 forLayer:self];
        [particlesArray addObject:temp];
    }
}
-(void)createDustDotsMid
{
    int multiplier = 0; //for 4 inch display
    if (CENTERY > 240) multiplier = 1;
    Particle *temp;
    for (int i=0;i<100;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(10+arc4random()%300, 140+multiplier*29-3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1 forLayer:self];
        [particlesArray addObject:temp];
    }
}
-(void)createDustDotsTop
{
    int multiplier = 0; //for 4 inch display
    if (CENTERY > 240) multiplier = 1;
    Particle *temp;
    for (int i=0;i<100;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(10+arc4random()%300, 280+multiplier*58-3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1 forLayer:self];
        [particlesArray addObject:temp];
    }
}

-(void)createBuyItemDots:(int)which //0 = bot, 2 = top
{
    int multiplier = 0; //for 4 inch display
    if (CENTERY > 240) multiplier = 1;
    Particle *temp;
    for (int i=0;i<400;i++)
    {
        float vx, vy;
        vx = -350+700*(arc4random()%1000)/1000.0;
        vy = -350+700*(arc4random()%1000)/1000.0;
        
        float y;
        if (which == 0) y = (140+multiplier*29)/2.0 + (20-arc4random()%41);
        else if (which == 1) y = 3*(140+multiplier*29)/2.0 + (20-arc4random()%41);
        else y = 5*(140+multiplier*29)/2.0 + (20-arc4random()%41);
        
        NSString *fileName;
        int whichColor = arc4random()%1000;
        if (whichColor < 200) fileName = @"particle_blackDot.png";
        else if (whichColor < 400) fileName = @"particle_redDot.png";
        else if (whichColor < 600) fileName = @"particle_greenDot.png";
        else if (whichColor < 800) fileName = @"particle_blueDot.png";
        else fileName = @"particle_purpleDot.png";
        
        temp = [[Particle alloc] initWithFileName:fileName atPoint:CGPointMake(100+arc4random()%120, y) withV:CGPointMake(vx, vy) withA:CGPointMake(-vx*1.2, -vy*1.2) withDScale:0 withDOpacity:-254 withDuration:1 forLayer:self];
        [particlesArray addObject:temp];
    }
}



-(void)updateIcons
{
    CGPoint pBot, pMid, pTop;
    pBot = currentIcon_bot.position;
    pMid = currentIcon_mid.position;
    pTop = currentIcon_top.position;
    
    [self removeChild:currentIcon_bot cleanup:YES];
    [self removeChild:currentIcon_mid cleanup:YES];
    [self removeChild:currentIcon_top cleanup:YES];
    switch (currentPageNum)
    {
        case 1:
            currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_item3.png"];
            currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_item2.png"];
            currentIcon_top = [CCSprite spriteWithFile:@"shop_background_item1.png"];
            break;
        case 2:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item6"])
                currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_greenOwned.png"];
            else
                currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_green.png"];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item5"])
                currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_blueOwned.png"];
            else
                currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_blue.png"];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item4"])
                currentIcon_top = [CCSprite spriteWithFile:@"shop_background_blackOwned.png"];
            else
                currentIcon_top = [CCSprite spriteWithFile:@"shop_background_black.png"];
            break;
        case 3:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item9"])
                currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_starOwned.png"];
            else
                currentIcon_bot = [CCSprite spriteWithFile:@"shop_background_star.png"];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item8"])
                currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_diamondOwned.png"];
            else
                currentIcon_mid = [CCSprite spriteWithFile:@"shop_background_diamond.png"];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shop_item7"])
                currentIcon_top = [CCSprite spriteWithFile:@"shop_background_squareOwned.png"];
            else
                currentIcon_top = [CCSprite spriteWithFile:@"shop_background_square.png"];
            break;
        default:
            break;
    }
    
    currentIcon_bot.position = ccp(pBot.x, pBot.y);
    [self addChild:currentIcon_bot];
    currentIcon_mid.position = ccp(pMid.x, pMid.y);
    [self addChild:currentIcon_mid];
    currentIcon_top.position = ccp(pTop.x, pTop.y);
    [self addChild:currentIcon_top];

}

-(void)showPage1
{
    [self showPage:1];
}
-(void)showPage:(int)n
{
    [changeMenu setEnabled:NO];
    pageIsFalling = YES;
    showPage_n = n;
    
    [currentChallenge_bot removeAllChildrenWithCleanup:YES];
    [currentChallenge_mid removeAllChildrenWithCleanup:YES];
    [currentChallenge_top removeAllChildrenWithCleanup:YES];
    
    [self reorderChild:currentIcon_bot z:1];
    [self reorderChild:currentIcon_mid z:1];
    [self reorderChild:currentIcon_top z:1];
    [self reorderChild:label_top z:1];
    [self reorderChild:label_mid z:1];
    [self reorderChild:label_bot z:1];
    [self reorderChild:title_top z:1];
    [self reorderChild:title_mid z:1];
    [self reorderChild:title_bot z:1];
    
    
    if ([[self children] containsObject:currentChallenge_bot])
    {
        //next
        if (n > currentPageNum)
        {
            [currentChallenge_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentChallenge_bot.position.y)]];
            [currentChallenge_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentChallenge_mid.position.y)]];
            [currentChallenge_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentChallenge_top.position.y)]];
            [currentIcon_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentIcon_bot.position.y)]];
            [currentIcon_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentIcon_mid.position.y)]];
            [currentIcon_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, currentIcon_top.position.y)]];
            [label_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_bot.position.y)]];
            [label_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_mid.position.y)]];
            [label_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_top.position.y)]];
            [title_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_bot.position.y)]];
            [title_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_mid.position.y)]];
            [title_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_top.position.y)]];
            [buyBotMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, buyBotMenu.position.y)]];
            [buyMidMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, buyMidMenu.position.y)]];
            [buyTopMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, buyTopMenu.position.y)]];
        }
        //previous
        else
        {
            [currentChallenge_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, 0)]];
            [currentChallenge_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, 0)]];
            [currentChallenge_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, 0)]];
            [currentIcon_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentIcon_bot.position.y)]];
            [currentIcon_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentIcon_mid.position.y)]];
            [currentIcon_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentIcon_top.position.y)]];
            [label_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_bot.position.y)]];
            [label_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_mid.position.y)]];
            [label_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_top.position.y)]];
            [title_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_bot.position.y)]];
            [title_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_mid.position.y)]];
            [title_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_top.position.y)]];
            [buyBotMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, buyBotMenu.position.y)]];
            [buyMidMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, buyMidMenu.position.y)]];
            [buyTopMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, buyTopMenu.position.y)]];
        }
    }
    
    [self scheduleOnce:@selector(finishShowPage) delay:.3];
    
    
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentPageNum-1] setNormalImage:[CCSprite spriteWithFile:@"instructions_circleLight.png"]];
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentPageNum-1] setSelectedImage:[CCSprite spriteWithFile:@"instructions_circleLight.png"]];
    
    currentPageNum = n;
    
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentPageNum-1] setNormalImage:[CCSprite spriteWithFile:@"instructions_circleDark.png"]];
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentPageNum-1] setSelectedImage:[CCSprite spriteWithFile:@"instructions_circleDark.png"]];
    
    
}

-(void)finishShowPage
{
    int n = showPage_n;
    
    //clear all currently running actions
    [currentChallenge_bot stopAllActions];
    [currentChallenge_mid stopAllActions];
    [currentChallenge_top stopAllActions];
    [currentIcon_bot stopAllActions];
    [currentIcon_mid stopAllActions];
    [currentIcon_top stopAllActions];
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];
    [buyBotMenu stopAllActions];
    [buyMidMenu stopAllActions];
    [buyTopMenu stopAllActions];
    
    
    int multiplier; //for 4 inch display
    multiplier = (CENTERY > 240)?1:0;
    
    
    [currentChallenge_top setVisible:YES];
    [currentChallenge_mid setVisible:YES];
    [currentChallenge_bot setVisible:YES];
    
    //icons
    [self updateIcons];
    
    [currentIcon_bot setVisible:YES];
    [currentIcon_mid setVisible:YES];
    [currentIcon_top setVisible:YES];
    
    currentChallenge_bot.position = ccp(160, 0+400);
    currentChallenge_mid.position = ccp(160, 140+multiplier*29+1000);
    currentChallenge_top.position = ccp(160, 280+multiplier*58+1600);
    currentIcon_bot.position = ccp(160, 0+400);
    currentIcon_mid.position = ccp(160, 140+multiplier*29+1000);
    currentIcon_top.position = ccp(160, 280+multiplier*58+1600);
    title_bot.position = ccp(160, 120+400);
    title_mid.position = ccp(160, 260+multiplier*29+1000);
    title_top.position = ccp(160, 400+multiplier*58+1600);
    label_bot.position = ccp(160, 45+400-((n==1)?7:0));
    label_mid.position = ccp(160, 185+multiplier*29+1000-((n==1)?7:0));
    label_top.position = ccp(160, 325+multiplier*58+1600-((n==1)?7:0));
    buyBotMenu.position = ccp(160, 84);
    buyMidMenu.position = ccp(160, 140+multiplier*29+84);
    buyTopMenu.position = ccp(160, 280+multiplier*58+84);
    
    [buyBotMenu setOpacity:0];
    [buyMidMenu setOpacity:0];
    [buyTopMenu setOpacity:0];
    [buyBotMenu setEnabled:NO];
    [buyMidMenu setEnabled:NO];
    [buyTopMenu setEnabled:NO];
    
    //if page 1, labels need #owned
    if (currentPageNum == 1)
    {
        [label_bot setString:[NSString stringWithFormat:@"%@%d",
                              [costsArray objectAtIndex:2],
                              [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]
                              ]];
        [label_mid setString:[NSString stringWithFormat:@"%@%d",
                              [costsArray objectAtIndex:1],
                              [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]
                              ]];
        [label_top setString:[NSString stringWithFormat:@"%@%d",
                              [costsArray objectAtIndex:0],
                              [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]
                              ]];
    }
    else
    {
        [label_bot setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3+2],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(n-1)*3+2]])
                          ? @"Owned. Equip this skin in Settings." : [costsArray objectAtIndex:(n-1)*3+2]]];
        
        [label_mid setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3+1],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(n-1)*3+1]])
                          ? @"Owned. Equip this skin in Settings." : [costsArray objectAtIndex:(n-1)*3+1]]];
        
        [label_top setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(n-1)*3]])
                          ? @"Owned. Equip this skin in Settings." : [costsArray objectAtIndex:(n-1)*3]]];
    }
    [title_bot setString:[namesArray objectAtIndex:(n-1)*3+2]];
    [title_mid setString:[namesArray objectAtIndex:(n-1)*3+1]];
    [title_top setString:[namesArray objectAtIndex:(n-1)*3]];

    
    [currentChallenge_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 0)]];
    [currentChallenge_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 140+multiplier*29)]];
    [currentChallenge_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 280+multiplier*58)]];
    [currentIcon_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 70+multiplier*29/2)]];
    [currentIcon_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, (70+multiplier*29/2)*3)]];
    [currentIcon_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, (70+multiplier*29/2)*5)]];
    [title_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 120)]];
    [title_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 260+multiplier*29)]];
    [title_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 400+multiplier*58)]];
    [label_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 45-((n==1)?7:0))]];
    [label_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 185+multiplier*29-((n==1)?7:0))]];
    [label_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 325+multiplier*58-((n==1)?7:0))]];
    [self scheduleOnce:@selector(createDustDotsBot) delay:.2];
    [self scheduleOnce:@selector(createDustDotsMid) delay:.5];
    [self scheduleOnce:@selector(createDustDotsTop) delay:.8];
    
    [self scheduleOnce:@selector(enableChange) delay:1];
}

-(void)enableChange
{
    [changeMenu setEnabled:YES];
    pageIsFalling = NO;
    
    [buyBotMenu setOpacity:0];
    [buyMidMenu setOpacity:0];
    [buyTopMenu setOpacity:0];
    
    if (currentPageNum == 1 || ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(currentPageNum-1)*3+2]])
    {
        [buyBotMenu setEnabled:YES];

        //check if can't afford
        if ([self dotPoints] < costValues[currentPageNum*3-1])
        {
            CGPoint oldPos = buyBotMenu.position;
            [self removeChild:buyBotMenu cleanup:YES];
            
            buyBot = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
            buyBotMenu = [CCMenu menuWithItems:buyBot, nil];
            [self addChild:buyBotMenu];
            buyBotMenu.opacity = 0;
            buyBotMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyBotMenu z:500];
        }
        else
        {
            //can afford
            CGPoint oldPos = buyBotMenu.position;
            [self removeChild:buyBotMenu cleanup:YES];
            
            buyBot = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyBot)];
            buyBotMenu = [CCMenu menuWithItems:buyBot, nil];
            [self addChild:buyBotMenu];
            buyBotMenu.opacity = 0;
            buyBotMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyBotMenu z:500];
        }
        
        [buyBotMenu runAction:[CCFadeIn actionWithDuration:.75]];
    }
    else
        [buyBotMenu setEnabled:NO];
    
    if (currentPageNum == 1 || ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(currentPageNum-1)*3+1]])
    {
        [buyMidMenu setEnabled:YES];
        
        //check if can't afford
        if ([self dotPoints] < costValues[currentPageNum*3-2])
        {
            CGPoint oldPos = buyMidMenu.position;
            [self removeChild:buyMidMenu cleanup:YES];
            
            buyMid = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
            buyMidMenu = [CCMenu menuWithItems:buyMid, nil];
            [self addChild:buyMidMenu];
            buyMidMenu.opacity = 0;
            buyMidMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyMidMenu z:500];
        }
        else
        {
            //can afford
            CGPoint oldPos = buyMidMenu.position;
            [self removeChild:buyMidMenu cleanup:YES];
            
            buyMid = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyMid)];
            buyMidMenu = [CCMenu menuWithItems:buyMid, nil];
            [self addChild:buyMidMenu];
            buyMidMenu.opacity = 0;
            buyMidMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyMidMenu z:500];
        }

        
        [buyMidMenu runAction:[CCFadeIn actionWithDuration:.75]];
    }
    else
        [buyMidMenu setEnabled:NO];
    
    if (currentPageNum == 1 || ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", 1+(currentPageNum-1)*3]])
    {
        [buyTopMenu setEnabled:YES];
        
        //check if can't afford
        if ([self dotPoints] < costValues[currentPageNum*3-3])
        {
            CGPoint oldPos = buyTopMenu.position;
            [self removeChild:buyTopMenu cleanup:YES];
            
            buyTop = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
            buyTopMenu = [CCMenu menuWithItems:buyTop, nil];
            [self addChild:buyTopMenu];
            buyTopMenu.opacity = 0;
            buyTopMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyTopMenu z:500];
        }
        else
        {
            //can afford
            CGPoint oldPos = buyTopMenu.position;
            [self removeChild:buyTopMenu cleanup:YES];
            
            buyTop = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyTop)];
            buyTopMenu = [CCMenu menuWithItems:buyTop, nil];
            [self addChild:buyTopMenu];
            buyTopMenu.opacity = 0;
            buyTopMenu.position = ccp(oldPos.x, oldPos.y);
            [self reorderChild:buyTopMenu z:500];
        }

        
        [buyTopMenu runAction:[CCFadeIn actionWithDuration:.75]];
    }
    else
        [buyTopMenu setEnabled:NO];

}

-(void)buyBot
{
    if (currentPageNum == 1)
    {
        if ([self dotPoints] >= costValues[2])
        {
            [self setDotPoints:[self dotPoints]-costValues[2]];
            [[NSUserDefaults standardUserDefaults] setInteger:1+[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"] forKey:@"shop_item3"];
            
            //check if can still afford
            [self checkCanAfford];
            
            //update #owned 
            [label_bot setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:2],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]
                                  ]];
            [label_mid setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:1],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]
                                  ]];
            [label_top setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:0],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]
                                  ]];
            
            //+1
            Particle *plus1 = [[Particle alloc] initWithFileName:@"shop_plus1.png" atPoint:buyBotMenu.position withV:CGPointMake(0, 150) withA:CGPointMake(0, 0) withDScale:0 withDOpacity:-255 withDuration:.5 forLayer:self];
            [self reorderChild:plus1.mySprite z:1000];
            [particlesArray addObject:plus1];
        }
    }
    else
    {
        if ([self dotPoints] >= costValues[3*currentPageNum-1])
        {
            [self setDotPoints:[self dotPoints]-costValues[3*currentPageNum-1]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"shop_item%d", 3*currentPageNum]];
            [buyBotMenu setEnabled:NO];
            buyBotMenu.opacity = 0;
            [buyBotMenu stopAllActions];
            
            [label_bot setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3+2],
                                  @"Owned. Equip this skin in Settings."]];

            
            [self updateIcons];
            
            [self createBuyItemDots:0];
        }
    }
}
-(void)buyMid
{
    if (currentPageNum == 1)
    {
        if ([self dotPoints] >= costValues[1])
        {
            [self setDotPoints:[self dotPoints]-costValues[1]];
            [[NSUserDefaults standardUserDefaults] setInteger:1+[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"] forKey:@"shop_item2"];
            
            //check if can still afford
            [self checkCanAfford];
            
            //update #owned
            [label_bot setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:2],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]
                                  ]];
            [label_mid setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:1],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]
                                  ]];
            [label_top setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:0],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]
                                  ]];

            
            //+1
            Particle *plus1 = [[Particle alloc] initWithFileName:@"shop_plus1.png" atPoint:buyMidMenu.position withV:CGPointMake(0, 150) withA:CGPointMake(0, 0) withDScale:0 withDOpacity:-255 withDuration:.5 forLayer:self];
            [self reorderChild:plus1.mySprite z:1000];
            [particlesArray addObject:plus1];

        }
    }
    else
    {
        if ([self dotPoints] >= costValues[3*currentPageNum-2])
        {
            [self setDotPoints:[self dotPoints]-costValues[3*currentPageNum-2]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"shop_item%d", 3*currentPageNum-1]];
            [buyMidMenu setEnabled:NO];
            buyMidMenu.opacity = 0;
            [buyMidMenu stopAllActions];
            
            [label_mid setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3+1],
                                  @"Owned. Equip this skin in Settings."]];
            
            [self updateIcons];
            
            [self createBuyItemDots:1];
        }
    }
}
-(void)buyTop
{
    if (currentPageNum == 1)
    {
        if ([self dotPoints] >= costValues[0])
        {
            [self setDotPoints:[self dotPoints]-costValues[0]];
            [[NSUserDefaults standardUserDefaults] setInteger:1+[[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"] forKey:@"shop_item1"];
            
            //check if can still afford
            [self checkCanAfford];
            
            //update #owned
            [label_bot setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:2],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item3"]
                                  ]];
            [label_mid setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:1],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item2"]
                                  ]];
            [label_top setString:[NSString stringWithFormat:@"%@%d",
                                  [costsArray objectAtIndex:0],
                                  [[NSUserDefaults standardUserDefaults] integerForKey:@"shop_item1"]
                                  ]];

            
            //+1
            Particle *plus1 = [[Particle alloc] initWithFileName:@"shop_plus1.png" atPoint:buyTopMenu.position withV:CGPointMake(0, 150) withA:CGPointMake(0, 0) withDScale:0 withDOpacity:-255 withDuration:.5 forLayer:self];
            [self reorderChild:plus1.mySprite z:1000];
            [particlesArray addObject:plus1];

        }
    }
    else
    {
        if ([self dotPoints] >= costValues[3*currentPageNum-3])
        {
            [self setDotPoints:[self dotPoints]-costValues[3*currentPageNum-3]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"shop_item%d", 3*currentPageNum-2]];
            [buyTopMenu setEnabled:NO];
            buyTopMenu.opacity = 0;
            [buyTopMenu stopAllActions];
            
            [label_top setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3],
                                  @"Owned. Equip this skin in Settings."]];
            
            [self updateIcons];
            
            [self createBuyItemDots:2];
        }
    }
}

-(void)checkCanAfford
{
    //bot
    //check if can't afford
    if ([self dotPoints] < costValues[currentPageNum*3-1])
    {
        CGPoint oldPos = buyBotMenu.position;
        [self removeChild:buyBotMenu cleanup:YES];
        
        buyBot = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
        buyBotMenu = [CCMenu menuWithItems:buyBot, nil];
        [self addChild:buyBotMenu];
        buyBotMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyBotMenu z:500];
    }
    else
    {
        //can afford
        CGPoint oldPos = buyBotMenu.position;
        [self removeChild:buyBotMenu cleanup:YES];
        
        buyBot = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyBot)];
        buyBotMenu = [CCMenu menuWithItems:buyBot, nil];
        [self addChild:buyBotMenu];
        buyBotMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyBotMenu z:500];
    }
    
    //mid
    //check if can't afford
    if ([self dotPoints] < costValues[currentPageNum*3-2])
    {
        CGPoint oldPos = buyMidMenu.position;
        [self removeChild:buyMidMenu cleanup:YES];
        
        buyMid = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
        buyMidMenu = [CCMenu menuWithItems:buyMid, nil];
        [self addChild:buyMidMenu];
        buyMidMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyMidMenu z:500];
    }
    else
    {
        //can afford
        CGPoint oldPos = buyMidMenu.position;
        [self removeChild:buyMidMenu cleanup:YES];
        
        buyMid = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyMid)];
        buyMidMenu = [CCMenu menuWithItems:buyMid, nil];
        [self addChild:buyMidMenu];
        buyMidMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyMidMenu z:500];
    }
    
    //top
    //check if can't afford
    if ([self dotPoints] < costValues[currentPageNum*3-3])
    {
        CGPoint oldPos = buyTopMenu.position;
        [self removeChild:buyTopMenu cleanup:YES];
        
        buyTop = [CCMenuItemImage itemWithNormalImage:@"shop_buyGrayed.png" selectedImage:@"shop_buyGrayed.png" target:self selector:@selector(cantAfford)];
        buyTopMenu = [CCMenu menuWithItems:buyTop, nil];
        [self addChild:buyTopMenu];
        buyTopMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyTopMenu z:500];
    }
    else
    {
        //can afford
        CGPoint oldPos = buyTopMenu.position;
        [self removeChild:buyTopMenu cleanup:YES];
        
        buyTop = [CCMenuItemImage itemWithNormalImage:@"shop_buy.png" selectedImage:@"shop_buySelected.png" target:self selector:@selector(buyTop)];
        buyTopMenu = [CCMenu menuWithItems:buyTop, nil];
        [self addChild:buyTopMenu];
        buyTopMenu.position = ccp(oldPos.x, oldPos.y);
        [self reorderChild:buyTopMenu z:500];
    }
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    dragStart = location;
    previousPoint = location;
    isSwiping = YES;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.x == previousPoint.x) return;
    
    if (isSwiping/* && !pageIsFalling*/)
    {
        float dx = location.x-previousPoint.x;
        
        if (!hasStartedMoving)
        {
            if (dx > 0) isMovingRight = YES;
            else isMovingRight = NO;
        }
        else
        {
            //has started moving, check for going wrong direction
            if (isMovingRight && dx < 0) {isSwiping = NO; return;}
            else if (!isMovingRight && dx > 0) {isSwiping = YES; return;}
        }
        
        
        //check for swiping right
        if (isMovingRight && hasStartedMoving && location.x-dragStart.x >= MIN_MOVE_FOR_SWIPE)
        {
            isSwiping = NO;
            [self previous];
        }
        //swiping left
        else if (!isMovingRight && hasStartedMoving && dragStart.x-location.x >= MIN_MOVE_FOR_SWIPE)
        {
            isSwiping = NO;
            [self next];
        }
    }
    previousPoint = location;
    hasStartedMoving = YES;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    hasStartedMoving = NO;
}



-(void)updateDotPoints:(int)deltaPoints
{
    numUpdateDPLoops = 0;
    DPinitial = [self dotPoints];
    DPgained = deltaPoints;
    [self schedule:@selector(updateDotPointsLoop) interval:1/30.0];
    [[NSUserDefaults standardUserDefaults] setInteger:[self dotPoints]+DPgained forKey:@"dotPoints"];    
}
-(void)updateDotPointsLoop
{
    dotPoints.string = [NSString stringWithFormat:@"Your Dot Points: %d", DPinitial+(int)(DPgained*numUpdateDPLoops/12.0)];
    numUpdateDPLoops++;
    if (numUpdateDPLoops == 12)
    {
        dotPoints.string = [NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]];
        [self unschedule:@selector(updateDotPointsLoop)];
    }
}

-(int)dotPoints
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotPoints"];
}
-(void)setDotPoints:(int)n
{
    [self updateDotPoints:n-[self dotPoints]];
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotPoints"];
}

@end
