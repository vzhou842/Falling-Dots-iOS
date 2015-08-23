//
//  ChallengesLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 6/25/13.
//
//

#import "ChallengesLayer.h"
#import "Particle.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0


@implementation ChallengesLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	ChallengesLayer *layer = [ChallengesLayer node];
	[scene addChild: layer];
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
        
        top = [CCSprite spriteWithFile:@"challenges_top.png"];
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
        for (int i=1;i<NUM_PAGES_CHALLENGES;i++)
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
                      @"Beginner",
                      @"Combo Apprentice",
                      @"Novice Scorer", //end pg 1
                      @"Journeyman",
                      @"Combo Ninja",
                      @"Intermediate Scorer", // end pg 2
                      @"Veteran",
                      @"Combo Master",
                      @"Good Scorer", //end pg 3
                      @"Great Scorer",
                      @"Really Great Scorer",
                      @"Ridiculous Scorer", //end pg 4
                      @"So Bad It's Negative",
                      @"LEET",
                      @"Dot Slayer", //end pg 5
                      @"Clearly Addicted",
                      @"How-Is-This-Possible Combo",
                      @"Must-Have-Cheated Scorer",nil];
        descriptionsArray = [[NSMutableArray alloc] initWithObjects:
                             @"Play 5 games.",
                             @"Get a 40 dot combo.",
                             @"Score 200 points in Classic Mode.", //end pg 1
                             @"Play 15 games.",
                             @"Get a 100 dot combo.",
                             @"Score 400 points in Arcade Mode.", //end pg 2
                             @"Play 50 games.",
                             @"Get a 200 dot combo.",
                             @"Score 1000 points in Classic Mode.", //end pg 3
                             @"Score 1500 points in Arcade Mode.",
                             @"Score 2500 points in Classic Mode.",
                             @"Score 4000 points in Arcade Mode.", //end pg 4
                             @"Score  <  -500 points in any Mode.",
                             @"Score exactly 1337 points in any Mode.",
                             @"Slay the Giant Dot.", //end pg 5
                             @"Play 250 games.",
                             @"Get a 500 dot combo.",
                             @"Score 10000 points in Classic Mode.",nil];
        rewardsArray = [[NSMutableArray alloc] initWithObjects:
                        @"+2 Dot Points",
                        @"+2 Dot Points",
                        @"+2 Dot Points", //end pg 1
                        @"+4 Dot Points",
                        @"+4 Dot Points",
                        @"+4 Dot Points", //end pg 2
                        @"+8 Dot Points",
                        @"+8 Dot Points",
                        @"+8 Dot Points", //end pg 3
                        @"+10 Dot Points", 
                        @"+15 Dot Points",
                        @"+20 Dot Points", //end pg 4
                        @"+30 Dot Points",
                        @"+30 Dot Points",
                        @"+30 Dot Points", //end pg 5
                        @"+100 Dot Points",
                        @"+100 Dot Points",
                        @"+100 Dot Points",nil];
        rewardValues[0] = 2; rewardValues[1] = 2; rewardValues[2] = 2;
        rewardValues[3] = 4; rewardValues[4] = 4; rewardValues[5] = 4;
        rewardValues[6] = 8; rewardValues[7] = 8; rewardValues[8] = 8;
        rewardValues[9] = 10; rewardValues[10] = 15; rewardValues[11] = 20;
        rewardValues[12] = 30; rewardValues[13] = 30; rewardValues[14] = 30;
        rewardValues[15] = 100; rewardValues[16] = 100; rewardValues[17] = 100;
        
        
        NSString *fileName = @"challenges_background.png";
        if (CENTERY > 240) fileName = @"challenges_background-tall.png";
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
        
        [self scheduleOnce:@selector(showPage1) delay:.3];
        currentPageNum = 1;
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
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];
    
    [self showPage:currentPageNum-1];
}

-(void)next
{
    if (currentPageNum >= NUM_PAGES_CHALLENGES)
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
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];

    [self showPage:currentPageNum+1];
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
-(void)createClaimRewards:(int)which //0 = bot, 2 = top
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
            [label_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_bot.position.y)]];
            [label_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_mid.position.y)]];
            [label_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, label_top.position.y)]];
            [title_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_bot.position.y)]];
            [title_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_mid.position.y)]];
            [title_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, title_top.position.y)]];
        }
        //previous
        else
        {
            [currentChallenge_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentChallenge_bot.position.y)]];
            [currentChallenge_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentChallenge_mid.position.y)]];
            [currentChallenge_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, currentChallenge_top.position.y)]];
            [label_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_bot.position.y)]];
            [label_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_mid.position.y)]];
            [label_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, label_top.position.y)]];
            [title_bot runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_bot.position.y)]];
            [title_mid runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_mid.position.y)]];
            [title_top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, title_top.position.y)]];
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
    [label_bot stopAllActions];
    [label_mid stopAllActions];
    [label_top stopAllActions];
    [title_bot stopAllActions];
    [title_mid stopAllActions];
    [title_top stopAllActions];
    
    int multiplier; //for 4 inch display
    multiplier = (CENTERY > 240)?1:0;
    
    //get backgrounds right
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3+2]])
        [currentChallenge_bot setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    else
        [currentChallenge_bot setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_background-tall.png":@"challenges_background.png"] texture]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3+1]])
        [currentChallenge_mid setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    else
        [currentChallenge_mid setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_background-tall.png":@"challenges_background.png"] texture]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3+0]])
        [currentChallenge_top setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    else
        [currentChallenge_top setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_background-tall.png":@"challenges_background.png"] texture]];
    
    [currentChallenge_top setVisible:YES];
    [currentChallenge_mid setVisible:YES];
    [currentChallenge_bot setVisible:YES];
    
    currentChallenge_bot.position = ccp(160, 0+400);
    currentChallenge_mid.position = ccp(160, 140+multiplier*29+1000);
    currentChallenge_top.position = ccp(160, 280+multiplier*58+1600);
    title_bot.position = ccp(160, 120+400);
    title_mid.position = ccp(160, 260+multiplier*29+1000);
    title_top.position = ccp(160, 400+multiplier*58+1600);
    label_bot.position = ccp(160, 45+400);
    label_mid.position = ccp(160, 185+multiplier*29+1000);
    label_top.position = ccp(160, 325+multiplier*58+1600);
    
    [label_bot setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3+2],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3+2]])
                          ? @"Reward Claimed" : [rewardsArray objectAtIndex:(n-1)*3+2]]];
    [label_mid setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3+1],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3+1]])
                          ? @"Reward Claimed" : [rewardsArray objectAtIndex:(n-1)*3+1]]];
    [label_top setString:[NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(n-1)*3],
                          ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(n-1)*3]])
                          ? @"Reward Claimed" : [rewardsArray objectAtIndex:(n-1)*3]]];
    [title_bot setString:[namesArray objectAtIndex:(n-1)*3+2]];
    [title_mid setString:[namesArray objectAtIndex:(n-1)*3+1]];
    [title_top setString:[namesArray objectAtIndex:(n-1)*3]];
    

    [currentChallenge_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 0)]];
    [currentChallenge_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 140+multiplier*29)]];
    [currentChallenge_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 280+multiplier*58)]];
    [title_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 120)]];
    [title_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 260+multiplier*29)]];
    [title_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 400+multiplier*58)]];
    [label_bot runAction:[CCMoveTo actionWithDuration:.2 position:CGPointMake(160, 45)]];
    [label_mid runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 185+multiplier*29)]];
    [label_top runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(160, 325+multiplier*58)]];
    [self scheduleOnce:@selector(createDustDotsBot) delay:.2];
    [self scheduleOnce:@selector(createDustDotsMid) delay:.5];
    [self scheduleOnce:@selector(createDustDotsTop) delay:.8];
    
    [self scheduleOnce:@selector(enableChange) delay:.8];
}

-(void)enableChange
{
    [changeMenu setEnabled:YES];
    pageIsFalling = NO;
    
    //check for claim rewards
    CCSprite *fade75;
    CCMenu *claimMenu;
    CCMenuItemImage *claim;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasCompletedChallenge%d", 1+(currentPageNum-1)*3]] && ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(currentPageNum-1)*3]])
    {
        //claim top
        fade75 = [CCSprite spriteWithFile:(CENTERY>240)?@"challenges_fade75-tall.png":@"challenges_fade75.png"];
        [currentChallenge_top addChild:fade75];
        fade75.opacity = 0;
        fade75.position = ccp(150,(CENTERY>240)?84.5:70);
        [fade75 runAction:[CCFadeIn actionWithDuration:.5]];
        
        claim = [CCMenuItemImage itemWithNormalImage:@"challenges_claimReward.png" selectedImage:@"challenges_claimRewardSelected.png" target:self selector:@selector(claimTop)];
        claimMenu = [CCMenu menuWithItems:claim, nil];
        [currentChallenge_top addChild:claimMenu];
        claimMenu.opacity = 0;
        claimMenu.position = ccp(150,(CENTERY>240)?84.5:70);
        [claimMenu runAction:[CCFadeIn actionWithDuration:.5]];
        
        [self reorderChild:label_top z:-1];
        
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasCompletedChallenge%d", 1+(currentPageNum-1)*3+1]] && ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(currentPageNum-1)*3+1]])
    {
        //claim mid
        fade75 = [CCSprite spriteWithFile:(CENTERY>240)?@"challenges_fade75-tall.png":@"challenges_fade75.png"];
        [currentChallenge_mid addChild:fade75];
        fade75.opacity = 0;
        fade75.position = ccp(150,(CENTERY>240)?84.5:70);
        [fade75 runAction:[CCFadeIn actionWithDuration:.5]];
        
        claim = [CCMenuItemImage itemWithNormalImage:@"challenges_claimReward.png" selectedImage:@"challenges_claimRewardSelected.png" target:self selector:@selector(claimMid)];
        claimMenu = [CCMenu menuWithItems:claim, nil];
        [currentChallenge_mid addChild:claimMenu];
        claimMenu.opacity = 0;
        claimMenu.position = ccp(150,(CENTERY>240)?84.5:70);
        [claimMenu runAction:[CCFadeIn actionWithDuration:.5]];
        
       [self reorderChild:label_mid z:-1];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasCompletedChallenge%d", 1+(currentPageNum-1)*3+2]] && ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"hasClaimedChallenge%d", 1+(currentPageNum-1)*3+2]])
    {
        //claim bot
        fade75 = [CCSprite spriteWithFile:(CENTERY>240)?@"challenges_fade75-tall.png":@"challenges_fade75.png"];
        [currentChallenge_bot addChild:fade75];
        fade75.opacity = 0;
        fade75.position = ccp(150,(CENTERY>240)?84.5:70);
        [fade75 runAction:[CCFadeIn actionWithDuration:.5]];
        
        claim = [CCMenuItemImage itemWithNormalImage:@"challenges_claimReward.png" selectedImage:@"challenges_claimRewardSelected.png" target:self selector:@selector(claimBot)];
        claimMenu = [CCMenu menuWithItems:claim, nil];
        [currentChallenge_bot addChild:claimMenu];
        claimMenu.opacity = 0;
        claimMenu.position = ccp(150,(CENTERY>240)?84.5:70);
        [claimMenu runAction:[CCFadeIn actionWithDuration:.5]];
        
        [self reorderChild:label_bot z:-1];
    }
}

-(void)claimTop
{
    [currentChallenge_top removeAllChildrenWithCleanup:YES];
    [self setDotPoints:[self dotPoints]+rewardValues[(currentPageNum-1)*3]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"hasClaimedChallenge%d",1+(currentPageNum-1)*3]];
    [currentChallenge_top setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    [self createClaimRewards:2];
    label_top.string = [NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3], @"Reward Claimed"];
    [self reorderChild:label_top z:1];
}
-(void)claimMid
{
    [currentChallenge_mid removeAllChildrenWithCleanup:YES];
    [self setDotPoints:[self dotPoints]+rewardValues[(currentPageNum-1)*3+1]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"hasClaimedChallenge%d",1+(currentPageNum-1)*3+1]];
    [currentChallenge_mid setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    [self createClaimRewards:1];
    label_mid.string = [NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3+1], @"Reward Claimed"];
    [self reorderChild:label_mid z:1];
}
-(void)claimBot
{
    [currentChallenge_bot removeAllChildrenWithCleanup:YES];
    [self setDotPoints:[self dotPoints]+rewardValues[(currentPageNum-1)*3+2]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"hasClaimedChallenge%d",1+(currentPageNum-1)*3+2]];
    [currentChallenge_bot setTexture:[[CCSprite spriteWithFile:(CENTERY>240)?@"challenges_backgroundCompleted-tall.png":@"challenges_backgroundCompleted.png"] texture]];
    [self createClaimRewards:0];
    label_bot.string = [NSString stringWithFormat:@"%@\n%@", [descriptionsArray objectAtIndex:(currentPageNum-1)*3+2], @"Reward Claimed"];
    [self reorderChild:label_bot z:1];
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



-(int)dotPoints
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotPoints"];
}
-(void)setDotPoints:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotPoints"];
}
@end