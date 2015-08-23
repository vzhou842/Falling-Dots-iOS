//
//  GameOverLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "UpgradesLayer.h"
#import "Appirater.h"
#import "AndrewJinLayer.h"
#import "GeorgeQiLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation GameOverLayer

- (void)reportScore:(int)s
{
    NSString *categoryString = @"victorzhougames.webs.com.ClassicLeaderboard";
    if (gameMode == ARCADE_MODE) categoryString = @"victorzhougames.webs.com.ArcadeLeaderboard";
    else if (gameMode == MULTIPLAYER_MODE) categoryString = @"com.victorzhougames.webs.MultiplayerLeaderboard";
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:categoryString] autorelease];
    scoreReporter.value = s;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
            NSLog(@"error reporting score");

        }
    }];
    
    //overall leaderboard
    categoryString = @"com.victorzhougames.webs.OverallLeaderboard";
    GKScore *scoreReporter2 = [[[GKScore alloc] initWithCategory:categoryString] autorelease];
    scoreReporter2.value = [self dotRating]+[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScore%d", CLASSIC_MODE]]+[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScore%d", ARCADE_MODE]];
    [scoreReporter2 reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
            NSLog(@"error reporting score");
            
        }
    }];
}


+(CCScene *) sceneWithScore:(int)s combo:(int)c forMode:(int)mode withAnimations:(bool)flag
{
	CCScene *scene = [CCScene node];
	GameOverLayer *layer = [[GameOverLayer alloc] initWithScore:s combo:c forMode:mode withAnimations:flag];
	[scene addChild: layer];
	return scene;
}

+(CCScene *) sceneFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDotRatingGain:(int)drg withAnimations:(bool)flag withDisconnect:(bool)dc
{
    CCScene *scene = [CCScene node];
	GameOverLayer *layer = [[GameOverLayer alloc] initFromMultiplayerWithPlayerScore:pScore enemyScore:eScore withDotRatingGain:drg withAnimations:flag withDisconnect:dc];
	[scene addChild: layer];
	return scene;
}

-(id)initWithScore:(int)s combo:(int)c forMode:(int)mode withAnimations:(bool)flag
{
    if (self = [super init])
    {
        gameMode = mode;
        
        //check if high score IF NOT GEORGE/JINZ MODE
        if (gameMode != ANDREW_JIN_MODE && gameMode != GEORGE_QI_MODE && s > [self bestScore])
        {
            [self setBestScore:s];
        }
        
        //report score if NOT ANDREWJIN/GEORGEQI modes
        if (gameMode != ANDREW_JIN_MODE && gameMode != GEORGE_QI_MODE)
            [self reportScore:s];
        score = s;
        combo = c;
        
        if (flag) timeMultiplier = 1; //with animations
        else timeMultiplier = 0; //no animations
        withAnimations = flag;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        //top
        top = [CCSprite spriteWithFile:@"gameOver_top.png"];
        top.position = ccp(160, 2*CENTERY-21+100);
        [self addChild:top];
        [top runAction:[CCMoveTo actionWithDuration:.5*timeMultiplier position:CGPointMake(160, 2*CENTERY-21)]];
        
        //back
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-500,2*CENTERY-21);
        [self addChild:backMenu];
        [backMenu runAction:[CCMoveTo actionWithDuration:3*timeMultiplier position:CGPointMake(15, 2*CENTERY-21)]];
        
        //round mode
        background_roundMode = [CCSprite spriteWithFile:@"gameOver_roundMode.png"];
        background_roundMode.position = ccp(160, YPOS_ROUNDMODE+800);
        [self addChild:background_roundMode];
        [background_roundMode runAction:[CCMoveTo actionWithDuration:1*timeMultiplier position:CGPointMake(160, YPOS_ROUNDMODE)]];
        
        NSString *modeString = @"Classic";
        if (gameMode == ARCADE_MODE) modeString = @"Arcade";
        else if (gameMode == ANDREW_JIN_MODE) modeString = @"Andrew Jin";
        else if (gameMode == GEORGE_QI_MODE) modeString = @"George Qi";
        roundMode = [CCLabelTTF labelWithString:modeString fontName:@"Eurostile" fontSize:18];
        roundMode.position = ccp(background_roundMode.position.x, background_roundMode.position.y-5);
        roundMode.color = ccBLACK;
        [self addChild:roundMode];
        [roundMode runAction:[CCMoveTo actionWithDuration:1*timeMultiplier position:CGPointMake(160, YPOS_ROUNDMODE-5)]];
        
        
        //best score
        background_best = [CCSprite spriteWithFile:@"gameOver_best.png"];
        background_best.position = ccp(160, YPOS_SCORES+1200);
        [self addChild:background_best];
        [background_best runAction:[CCMoveTo actionWithDuration:1.5*timeMultiplier position:CGPointMake(160, YPOS_SCORES)]];
        
        bestScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [self bestScore]] fontName:@"Eurostile" fontSize:20];
        bestScore.position = ccp(background_best.position.x, background_best.position.y-5);
        bestScore.color = ccBLACK;
        [self addChild:bestScore];
        [bestScore runAction:[CCMoveTo actionWithDuration:1.5*timeMultiplier position:CGPointMake(160, YPOS_SCORES-5)]];
        
        
        //this round
        background_thisRound = [CCSprite spriteWithFile:@"gameOver_thisRound.png"];
        background_thisRound.position = ccp(50-800*2, YPOS_SCORES);
        [self addChild:background_thisRound];
        [background_thisRound runAction:[CCMoveTo actionWithDuration:2*timeMultiplier position:CGPointMake(50, YPOS_SCORES)]];
        
        thisRoundScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", s] fontName:@"Eurostile" fontSize:20];
        thisRoundScore.position = ccp(background_thisRound.position.x, background_thisRound.position.y-5);
        thisRoundScore.color = ccBLACK;
        [self addChild:thisRoundScore];
        [thisRoundScore runAction:[CCMoveTo actionWithDuration:2*timeMultiplier position:CGPointMake(50, YPOS_SCORES-5)]];
        
        if (timeMultiplier == 1)
            [self scheduleOnce:@selector(createDustThisRound) delay:2];
    
        
        //combo
        background_combo = [CCSprite spriteWithFile:@"gameOver_combo.png"];
        background_combo.position = ccp(270+800*2.5, YPOS_SCORES);
        [self addChild:background_combo];
        [background_combo runAction:[CCMoveTo actionWithDuration:2.5*timeMultiplier position:CGPointMake(270, YPOS_SCORES)]];
        
        bestCombo = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", c] fontName:@"Eurostile" fontSize:20];
        bestCombo.position = ccp(background_combo.position.x, background_combo.position.y-5);
        bestCombo.color = ccBLACK;
        [self addChild:bestCombo];
        [bestCombo runAction:[CCMoveTo actionWithDuration:2.5*timeMultiplier position:CGPointMake(270, YPOS_SCORES-5)]];
        
        if (timeMultiplier == 1)
           [self scheduleOnce:@selector(createDustBestCombo) delay:2.5];
        
        
        
        
        [self scheduleOnce:@selector(addDotPointsLabels) delay:2.5*timeMultiplier];
        
        particlesArray = [[NSMutableArray alloc] init];
        [self schedule:@selector(updateParticles) interval:1/30.0];
        
        
        //challenges IF NOT ANDREW/GEORGE MODES
        if (gameMode != ANDREW_JIN_MODE && gameMode != GEORGE_QI_MODE && flag)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"]+1 forKey:@"numGamesPlayed"];
            
            //check for completions
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 5)
            {
                //beginner
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge1"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 15)
            {
                //journeyman
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge4"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 50)
            {
                //veteran
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge7"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 250)
            {
                //addict
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge16"];
            }
            
            if (mode == CLASSIC_MODE && s >= 200)
            {
                //novice
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge3"];
            }
            if (mode == ARCADE_MODE && s >= 400)
            {
                //intermediate
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge6"];
            }
            if (mode == CLASSIC_MODE && s >= 1000)
            {
                //expert
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge9"];
            }
            if (mode == ARCADE_MODE && s >= 1500)
            {
                //wtf scorer
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge10"];
            }
            if (mode == CLASSIC_MODE && s >= 2500)
            {
                //wtf scorer
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge11"];
            }
            if (mode == ARCADE_MODE && s >= 4000)
            {
                //wtf scorer
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge12"];
            }
            if (s < -500)
            {
                //troll < -500
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge13"];
            }
            if (s == 1337)
            {
                //troll 1337
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge14"];
            }
            if (mode == CLASSIC_MODE && s >= 10000)
            {
                //impossible scorer
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge18"];
            }
        
    
        }
    }
    return self;
}

-(id)initFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDotRatingGain:(int)dotrg withAnimations:(bool)flag withDisconnect:(bool)dc
{
    if (self = [super init])
    {
        gameMode = MULTIPLAYER_MODE;
        
        //report dot rating
        [self reportScore:[self dotRating]];
        
        if (flag) timeMultiplier = 1; //with animations
        else timeMultiplier = 0; //no animations
        withAnimations = flag;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        //top
        top = [CCSprite spriteWithFile:@"gameOver_top.png"];
        top.position = ccp(160, 2*CENTERY-21+100);
        [self addChild:top];
        [top runAction:[CCMoveTo actionWithDuration:.5*timeMultiplier position:CGPointMake(160, 2*CENTERY-21)]];
        
        //back
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-500,2*CENTERY-21);
        [self addChild:backMenu];
        [backMenu runAction:[CCMoveTo actionWithDuration:3*timeMultiplier position:CGPointMake(15, 2*CENTERY-21)]];
        
        //disconnect
        if (dc)
        {
            CCLabelTTF *dcLabel = [CCLabelTTF labelWithString:@"Game Disconnected" fontName:@"Eurostile" fontSize:28];
            dcLabel.position = ccp(160, CENTERY);
            [self addChild:dcLabel];
            dcLabel.opacity = 0;
            dcLabel.color = ccBLACK;
            [dcLabel runAction:[CCFadeIn actionWithDuration:1]];
            
            return self;
        }
        
        //round mode
        background_roundMode = [CCSprite spriteWithFile:@"gameOver_roundMode.png"];
        background_roundMode.position = ccp(160, YPOS_ROUNDMODE+800);
        [self addChild:background_roundMode];
        [background_roundMode runAction:[CCMoveTo actionWithDuration:1*timeMultiplier position:CGPointMake(160, YPOS_SCORES)]];

        roundMode = [CCLabelTTF labelWithString:@"Multiplayer" fontName:@"Eurostile" fontSize:18];
        roundMode.position = ccp(background_roundMode.position.x, background_roundMode.position.y-5);
        roundMode.color = ccBLACK;
        [self addChild:roundMode];
        [roundMode runAction:[CCMoveTo actionWithDuration:1*timeMultiplier position:CGPointMake(160, YPOS_SCORES-5)]];
        
        //your score
        background_thisRound = [CCSprite spriteWithFile:@"gameOver_yourScore.png"];
        background_thisRound.position = ccp(50-800*2, YPOS_SCORES);
        [self addChild:background_thisRound];
        [background_thisRound runAction:[CCMoveTo actionWithDuration:2*timeMultiplier position:CGPointMake(50, YPOS_SCORES)]];
        
        thisRoundScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", pScore] fontName:@"Eurostile" fontSize:20];
        thisRoundScore.position = ccp(background_thisRound.position.x, background_thisRound.position.y-5);
        thisRoundScore.color = ccBLACK;
        [self addChild:thisRoundScore];
        [thisRoundScore runAction:[CCMoveTo actionWithDuration:2*timeMultiplier position:CGPointMake(50, YPOS_SCORES-5)]];
        
        //enemy score
        background_combo = [CCSprite spriteWithFile:@"gameOver_enemyScore.png"];
        background_combo.position = ccp(270+800*2.5, YPOS_SCORES);
        [self addChild:background_combo];
        [background_combo runAction:[CCMoveTo actionWithDuration:2.5*timeMultiplier position:CGPointMake(270, YPOS_SCORES)]];
        
        bestCombo = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", eScore] fontName:@"Eurostile" fontSize:20];
        bestCombo.position = ccp(background_combo.position.x, background_combo.position.y-5);
        bestCombo.color = ccBLACK;
        [self addChild:bestCombo];
        [bestCombo runAction:[CCMoveTo actionWithDuration:2.5*timeMultiplier position:CGPointMake(270, YPOS_SCORES-5)]];
        
        
        if (timeMultiplier == 1)
            [self scheduleOnce:@selector(createDustThisRound) delay:2];

        
        
        if (timeMultiplier == 1)
            [self scheduleOnce:@selector(createDustBestCombo) delay:2.5];
        
        
        
        [self scheduleOnce:@selector(addDotPointsLabels) delay:2.5*timeMultiplier];
        
        if (pScore >= eScore && flag && dotrg > 0)
        {
            //player won, ranked game, make particles only if with animations
            drg = dotrg;
            [self scheduleOnce:@selector(makeMultiplayerParticles) delay:3];
        }
        
        
        particlesArray = [[NSMutableArray alloc] init];
        [self schedule:@selector(updateParticles) interval:1/30.0];
        
        
        //challenges
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"]+1 forKey:@"numGamesPlayed"];
            
            //check for completions
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 5)
            {
                //beginner
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge1"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 15)
            {
                //journeyman
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge4"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 50)
            {
                //veteran
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge7"];
            }
            else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"] == 250)
            {
                //addict
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge16"];
            }
            
            if (pScore < -500)
            {
                //troll < -500
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge13"];
            }
        
    }
    return self;

}

-(void)addDotPointsLabels
{
    if (hasUpdatedDotPoints) return;
    hasUpdatedDotPoints = YES;
    
    
    if (gameMode != ANDREW_JIN_MODE)
    {
        //leaderboard rank NOT FOR JINZ MODE
        CCLabelTTF *rankLabel = [CCLabelTTF labelWithString:@"Not Connected to Game Center" fontName:@"Eurostile" fontSize:14];
        rankLabel.position = ccp(160, 130+OFFSETY);
        rankLabel.color = ccBLACK;
        [self addChild:rankLabel];
        rankLabel.opacity = 0;
        [rankLabel runAction:[CCFadeIn actionWithDuration:.5*timeMultiplier]];
    
    
        //check if player is in game center
        if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            GKLeaderboard *leaderBoard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]];
            leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderBoard.category = @"victorzhougames.webs.com.ClassicLeaderboard";
            if (gameMode == ARCADE_MODE) leaderBoard.category = @"victorzhougames.webs.com.ArcadeLeaderboard";
            else if (gameMode == MULTIPLAYER_MODE) leaderBoard.category = @"com.victorzhougames.webs.MultiplayerLeaderboard";
            
    
            [leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error)
             {
                 if (error == nil)
                 {
                     for (GKScore *scoregk in scores)
                     {
                         if ([scoregk.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
                         {
                             GKLeaderboard *l = [[GKLeaderboard alloc] init];
                             l.timeScope = GKLeaderboardTimeScopeAllTime;
                             l.category = @"victorzhougames.webs.com.ClassicLeaderboard";
                             if (gameMode == ARCADE_MODE) l.category = @"victorzhougames.webs.com.ArcadeLeaderboard";
                             else if (gameMode == MULTIPLAYER_MODE) l.category = @"com.victorzhougames.webs.MultiplayerLeaderboard";
                             //__block NSUInteger numScores = 1;
                             [l loadScoresWithCompletionHandler:^(NSArray *scores2, NSError *error2)
                              {
                             //   NSLog(@"score count: %d", scores.count);
                                  // numScores = scores.count;
                                  [rankLabel setString:[NSString stringWithFormat:@"Leaderboard Rank: #%d out of %d players", scoregk.rank, l.maxRange]];
                                  
                                  //MULTIPLAYER show dot rating
                                  if (gameMode == MULTIPLAYER_MODE)
                                      [rankLabel setString:[NSString stringWithFormat:@"Your Dot Rating: %d\nLeaderboard Rank: #%d out of %d players", [self dotRating], scoregk.rank, l.maxRange]];
                                  
                              }];
                             //NSLog(@"numScores: %d", numScores);
                     
                     
                             return;
                         }
                     }
                 }
         
             }];
        }
    }
    
    //dot points left to spend - before dot points earned so setDotPoints has a label to adjust
    dotPointsSpendable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]] fontName:@"Eurostile" fontSize:20];
    dotPointsSpendable.position = ccp(160, CENTERY*1.1);
    dotPointsSpendable.color = ccBLACK;
    [self addChild:dotPointsSpendable];
    if (score > 50 && withAnimations && gameMode != MULTIPLAYER_MODE)
    {
        [self setDotPoints:[self dotPoints]+(score+50)/100];
        num_particle_dotPoints = (score+50)/100;
        [self scheduleOnce:@selector(makeDotPointsGainedParticles) delay:.5];
    }
    
    //more dots
    moreDots = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(moreDots)];
    moreDotsMenu = [CCMenu menuWithItems:moreDots, nil];
    moreDotsMenu.position = ccp(160+dotPointsSpendable.boundingBox.size.width/2.0+16, dotPointsSpendable.position.y);
    [self addChild:moreDotsMenu];
    
    //spend
    spend = [CCMenuItemImage itemWithNormalImage:@"gameOver_spend.png" selectedImage:@"gameOver_spendSelected.png" target:self selector:@selector(spend)];
    spendMenu = [CCMenu menuWithItems:spend, nil];
    spendMenu.position = ccp(160, dotPointsSpendable.position.y-35);
    [self addChild:spendMenu];
    
    
    //dot points earned
    /*dotPointsEarned = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"You earned %d Dot Points this round.", (score+50)/100] fontName:@"Eurostile" fontSize:16];
    dotPointsEarned.position = ccp(160, 200-44+OFFSETY);
    dotPointsEarned.color = ccBLACK;
    [self addChild:dotPointsEarned];*/
    
    //[self setDotPoints:[self dotPoints]+(s+50)/100]; <- CALLED MULTIPLE TIMES, MUST BE DELAYED
    
    
    if (gameMode != ANDREW_JIN_MODE && gameMode != MULTIPLAYER_MODE)
    {
        //play again but NOT FOR JINZ MODE OR MULTIPLAYER
        playAgain = [CCMenuItemImage itemWithNormalImage:@"gameOver_playAgain.png" selectedImage:@"gameOver_playAgainSelected.png" target:self selector:@selector(playAgain)];
        playAgainMenu = [CCMenu menuWithItems:playAgain, nil];
        playAgainMenu.position = ccp(160, 40);
        [self addChild:playAgainMenu];
        
        
        playAgainMenu.opacity = 0;
        [playAgainMenu runAction:[CCFadeIn actionWithDuration:.5*timeMultiplier]];
    }
    
    
    dotPointsSpendable.opacity = 0;
    //dotPointsEarned.opacity = 0;
    moreDotsMenu.opacity = 0;
    spendMenu.opacity = 0;
    [dotPointsSpendable runAction:[CCFadeIn actionWithDuration:.5]];
    //[dotPointsEarned runAction:[CCFadeIn actionWithDuration:.5]];
    [moreDotsMenu runAction:[CCFadeIn actionWithDuration:.5*timeMultiplier]];
    [spendMenu runAction:[CCFadeIn actionWithDuration:.5*timeMultiplier]];
    
    //appirater
    if (withAnimations)
        [self scheduleOnce:@selector(addSignificantEvent) delay:.5];
}
-(void)addSignificantEvent
{
    [Appirater userDidSignificantEvent:YES];
}
-(void)updateParticles;
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
-(void)spend
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:[UpgradesLayer sceneWithScore:score combo:combo forMode:gameMode fromMainMenu:NO]]];
}
-(void)playAgain
{
    if (gameMode == ANDREW_JIN_MODE)
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[AndrewJinLayer sceneForMode:gameMode]]];
    else if (gameMode == GEORGE_QI_MODE)
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[GeorgeQiLayer sceneForMode:gameMode]]];
    else
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[GameLayer sceneForMode:gameMode]]];
}


-(void)updateDotPoints
{
    numUpdateDPLoops = 0;
    DPinitial = [self dotPoints];
    [self schedule:@selector(updateDotPointsLoop) interval:1/30.0];
    [[NSUserDefaults standardUserDefaults] setInteger:[self dotPoints]+DPgained forKey:@"dotPoints"];
    
}
-(void)updateDotPointsLoop
{
    dotPointsSpendable.string = [NSString stringWithFormat:@"Your Dot Points: %d", DPinitial+(int)(DPgained*numUpdateDPLoops/20.0)];
    moreDotsMenu.position = ccp(160+dotPointsSpendable.boundingBox.size.width/2.0+16, dotPointsSpendable.position.y);
    numUpdateDPLoops++;
    if (numUpdateDPLoops == 20)
    {
        [self setDotPoints:[self dotPoints]]; //already added them directly through NSUserDefaults in updateDotPoints
        [self unschedule:@selector(updateDotPointsLoop)];
    }
}

/*
-(void)createDPexplosionSmall
{
    Particle *temp;
    for (int i=0;i<25;i++)
    {
        NSString *fileName;
        int rand = arc4random()%1000;
        if (rand < 200) fileName = @"particle_blackDot.png";
        else if (rand < 400) fileName = @"particle_greenDot.png";
        else if (rand < 600) fileName = @"particle_redDot.png";
        else if (rand < 800) fileName = @"particle_blueDot.png";
        else fileName = @"particle_purpleDot.png";
        
        float vx, vy;
        vx = -120+240*(arc4random()%1000)/1000.0;
        vy = -120+240*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:fileName atPoint:CGPointMake(dotPointsSpendable.position.x+85-20+arc4random()%41, dotPointsSpendable.position.y-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(-1.5*vx, -1.5*vy) withDScale:0 withDOpacity:-254 withDuration:.5 forLayer:self];
        [particlesArray addObject:temp];
    }
}
-(void)createDPexplosionBig
{
    Particle *temp;
    for (int i=0;i<40;i++)
    {
        NSString *fileName;
        int rand = arc4random()%1000;
        if (rand < 200) fileName = @"particle_blackDot.png";
        else if (rand < 400) fileName = @"particle_greenDot.png";
        else if (rand < 600) fileName = @"particle_redDot.png";
        else if (rand < 800) fileName = @"particle_blueDot.png";
        else fileName = @"particle_purpleDot.png";
        
        float vx, vy;
        vx = -200+400*(arc4random()%1000)/1000.0;
        vy = -200+400*(arc4random()%1000)/1000.0;
        temp = [[Particle alloc] initWithFileName:fileName atPoint:CGPointMake(dotPointsSpendable.position.x+85-20+arc4random()%41, dotPointsSpendable.position.y-10+arc4random()%21) withV:CGPointMake(vx, vy) withA:CGPointMake(-1.5*vx, -1.5*vy) withDScale:0 withDOpacity:-254 withDuration:.5 forLayer:self];
        [particlesArray addObject:temp];
    }
}
*/


-(void)makeMultiplayerParticles
{
    particle_dotPoints = [CCLabelTTF labelWithString:@"+18 Dot Points" fontName:@"Eurostile" fontSize:36];
    particle_dotRating = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d Dot Rating", drg] fontName:@"Eurostile" fontSize:36];
    particle_dotPoints.position = dotPointsSpendable.position;
    particle_dotRating.position = ccp(160, 135+OFFSETY);
    particle_dotPoints.color = ccc3(0, 240, 0);
    particle_dotRating.color = ccc3(0, 240, 0);
    [self addChild:particle_dotPoints];
    [self addChild:particle_dotRating];
    [particle_dotPoints runAction:[CCFadeOut actionWithDuration:1.5]];
    [particle_dotRating runAction:[CCFadeOut actionWithDuration:1.5]];
    [particle_dotPoints runAction:[CCMoveTo actionWithDuration:1.5 position:CGPointMake(dotPointsSpendable.position.x, dotPointsSpendable.position.y+125)]];
    [particle_dotRating runAction:[CCMoveTo actionWithDuration:1.5 position:CGPointMake(160, 135+OFFSETY+125)]];
    [self scheduleOnce:@selector(removeMultiplayerParticles) delay:1.5];
    
    if (drg <= 0) //don't show dot rating gained if 0 gained
        [particle_dotRating setVisible:NO];
}
-(void)removeMultiplayerParticles
{
    [self removeChild:particle_dotPoints cleanup:YES];
    [self removeChild:particle_dotRating cleanup:YES];
}

-(void)makeDotPointsGainedParticles
{
    particle_dotPoints = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d Dot Points", num_particle_dotPoints] fontName:@"Eurostile" fontSize:36];
    particle_dotPoints.position = dotPointsSpendable.position;
    particle_dotPoints.color = ccc3(0, 240, 0);
    [self addChild:particle_dotPoints];
    [particle_dotPoints runAction:[CCFadeOut actionWithDuration:1.5]];
    [particle_dotPoints runAction:[CCMoveTo actionWithDuration:1.5 position:CGPointMake(dotPointsSpendable.position.x, dotPointsSpendable.position.y+125)]];
    [self scheduleOnce:@selector(removeMakeDotPointsGainedParticles) delay:1.5];
}

-(void)removeMakeDotPointsGainedParticles
{
    [self removeChild:particle_dotPoints cleanup:YES];
}


-(void)createDustThisRound
{
    Particle *temp;
    for (int i=0;i<30;i++)
    {
        float vx, vy;
        vy = 40-80*(arc4random()%1000)/1000.0;
        vx = arc4random()%120;
        vx *= -1;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(100-arc4random()%5, YPOS_SCORES-25+arc4random()%51) withV:CGPointMake(vx, vy) withA:CGPointMake(50, -vy/2) withDScale:0 withDOpacity:-254 withDuration:.75 forLayer:self];
        temp.mySprite.scale = .75;
        [particlesArray addObject:temp];
    }
}
-(void)createDustBestCombo
{
    Particle *temp;
    for (int i=0;i<30;i++)
    {
        float vx, vy;
        vy = 40-80*(arc4random()%1000)/1000.0;
        vx = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(220+arc4random()%5, YPOS_SCORES-25+arc4random()%51) withV:CGPointMake(vx, vy) withA:CGPointMake(-50, -vy/2) withDScale:0 withDOpacity:-254 withDuration:.75 forLayer:self];
        temp.mySprite.scale = .75;
        [particlesArray addObject:temp];
    }
}



-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


//---------------------------------------I A P STUFF---------------------------------------
-(void)moreDots
{
    isInIAP = YES;
    [backMenu setEnabled:NO];
    [moreDotsMenu setEnabled:NO];
    [spendMenu setEnabled:NO];
    [playAgainMenu setEnabled:NO];
    
    faded75 = [CCSprite spriteWithFile:@"faded75.png"];
    faded75.position = ccp(160, CENTERY);
    [self addChild:faded75];
    
    background_IAP = [CCSprite spriteWithFile:@"gameOver_IAP.png"];
    background_IAP.position = ccp(160, 3*CENTERY);
    [self addChild:background_IAP];
    [background_IAP runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY)]];
    
    buy200 = [CCMenuItemImage itemWithNormalImage:@"IAP_buy200.png" selectedImage:@"IAP_buy200Selected.png" target:self selector:@selector(buy200)];
    buy500 = [CCMenuItemImage itemWithNormalImage:@"IAP_buy500.png" selectedImage:@"IAP_buy500Selected.png" target:self selector:@selector(buy500)];
    IAPmenu = [CCMenu menuWithItems:buy200, buy500, nil];
    IAPmenu.position = ccp(160, 3*CENTERY-15);
    [IAPmenu alignItemsVerticallyWithPadding:75];
    [self addChild:IAPmenu];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY-15)]];
    
    close = [CCMenuItemImage itemWithNormalImage:@"IAP_close.png" selectedImage:@"IAP_closeSelected.png" target:self selector:@selector(closeIAP)];
    IAPcloseMenu = [CCMenu menuWithItems:close, nil];
    IAPcloseMenu.position = ccp(160, 3*CENTERY-160);
    [self addChild:IAPcloseMenu];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY-160)]];
    
    IAP_loading = [CCSprite spriteWithFile:@"IAP_loading.png"];
    IAP_loading.position = ccp(480, CENTERY);
    [self addChild:IAP_loading];
}

-(void)buy200
{
    IAP_loading.position = ccp(480, CENTERY);
    [IAP_loading runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    
    [background_IAP runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY-160)]];
    
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.victorzhougames.webs.200DP"]];
    request.delegate = self;
    [request start];
}

-(void)buy500
{
    IAP_loading.position = ccp(480, CENTERY);
    [IAP_loading runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    
    [background_IAP runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY-160)]];
    
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.victorzhougames.webs.500DP"]];
    request.delegate = self;
    [request start];
}

-(void)closeIAP
{
    isInIAP = NO;
    [backMenu setEnabled:YES];
    [moreDotsMenu setEnabled:YES];
    [spendMenu setEnabled:YES];
    [playAgainMenu setEnabled:YES];
    
    [self removeChild:background_IAP cleanup:YES];
    [self removeChild:faded75 cleanup:YES];
    [self removeChild:IAPcloseMenu cleanup:YES];
    [self removeChild:IAPmenu cleanup:YES];
    [self removeChild:IAP_loading cleanup:YES];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
    
    //Since only one product, we do not need to choose from the array. Proceed directly to payment.
    
    SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:newPayment];
    
    [request autorelease];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    [self closeIAP];
    
    // Display an error here.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed"
                                                    message:[NSString stringWithFormat:@"Please try again - make sure you are connected to the internet."]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}


//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");

    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    if ([transaction.payment.productIdentifier isEqualToString:@"com.victorzhougames.webs.200DP"])
    {
        //+200
        hasUpdatedDotPoints = NO;
        DPgained = 200;
        [self scheduleOnce:@selector(updateDotPoints) delay:0];
        [self closeIAP];
    }
    else if ([transaction.payment.productIdentifier isEqualToString:@"com.victorzhougames.webs.500DP"])
    {
        //+500
        hasUpdatedDotPoints = NO;
        DPgained = 500;
        [self scheduleOnce:@selector(updateDotPoints) delay:0];
        [self closeIAP];
    }
    else NSLog(@"UNKNOWN PRODUCT IDENTIFIER: %@", transaction.payment.productIdentifier);
    
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restored");

    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];

    [self closeIAP];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    [self closeIAP];
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:[NSString stringWithFormat:@"Your purchase failed: %@. Please try again.", transaction.error.localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self closeIAP];
    if (error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:[NSString stringWithFormat:@"Your purchase failed: %@. Please try again.", error.localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

//------NSUSERDEFAULT STUFF------
-(int)bestScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScore%d", gameMode]];
}
-(void)setBestScore:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:[NSString stringWithFormat:@"highScore%d", gameMode]];
}
-(int)dotPoints
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotPoints"];
}
-(void)setDotPoints:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotPoints"];
    dotPointsSpendable.string = [NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]];
    moreDotsMenu.position = ccp(160+dotPointsSpendable.boundingBox.size.width/2.0+16, dotPointsSpendable.position.y);
}
-(int)dotRating
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotRating"];
}
-(void)setDotRating:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotRating"];
}
@end

