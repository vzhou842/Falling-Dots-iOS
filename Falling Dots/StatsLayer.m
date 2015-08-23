//
//  StatsLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 7/7/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "StatsLayer.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation StatsLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	StatsLayer *layer = [StatsLayer node];
	[scene addChild: layer];
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        background = [CCSprite spriteWithFile:@"background_personalStats.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        top = [CCSprite spriteWithFile:@"personalStats_top.png"];
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
        
        gamesPlayed = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Games Played: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"numGamesPlayed"]] fontName:@"Eurostile" fontSize:18];
        classic = [CCLabelTTF labelWithString:
                   [NSString stringWithFormat:@"Classic Mode High Score: %d", [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScore%d", CLASSIC_MODE]]]
                                     fontName:@"Eurostile"
                                     fontSize:18];
        arcade = [CCLabelTTF labelWithString:
                  [NSString stringWithFormat:@"Arcade Mode High Score: %d", [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"highScore%d", ARCADE_MODE]]]
                                    fontName:@"Eurostile"
                                    fontSize:18];
        multiplayer = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Dot Rating: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"dotRating"]] fontName:@"Eurostile" fontSize:18];
        combo = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Highest Combo Ever: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"bestCombo"]] fontName:@"Eurostile" fontSize:18];
        
        gamesPlayed.position = ccp(160, .75*CENTERY);
        classic.position = ccp(160, 1.6*CENTERY);
        arcade.position = ccp(160, 1.35*CENTERY);
        multiplayer.position = ccp(160, 1.1*CENTERY);
        combo.position = ccp(160, .45*CENTERY);
        gamesPlayed.color = ccBLACK;
        classic.color = ccBLACK;
        arcade.color = ccBLACK;
        multiplayer.color = ccBLACK;
        combo.color = ccBLACK;
        [self addChild:gamesPlayed];
        [self addChild:classic];
        [self addChild:arcade];
        [self addChild:multiplayer];
        [self addChild:combo];
        gamesPlayed.opacity = 0;
        classic.opacity = 0;
        arcade.opacity = 0;
        multiplayer.opacity = 0;
        combo.opacity = 0;
        
        
        //-----------check leaderboard ranks------------
        
        //ranks
        classicRank = [CCLabelTTF labelWithString:@"Not Connected to Game Center" fontName:@"Eurostile" fontSize:13];
        classicRank.position = ccp(160, 1.5*CENTERY);
        classicRank.color = ccBLACK;
        [self addChild:classicRank];
        classicRank.opacity = 0;
        
        arcadeRank = [CCLabelTTF labelWithString:@"Not Connected to Game Center" fontName:@"Eurostile" fontSize:13];
        arcadeRank.position = ccp(160, 1.25*CENTERY);
        arcadeRank.color = ccBLACK;
        [self addChild:arcadeRank];
        arcadeRank.opacity = 0;
        
        multiplayerRank = [CCLabelTTF labelWithString:@"Not Connected to Game Center" fontName:@"Eurostile" fontSize:13];
        multiplayerRank.position = ccp(160, 1*CENTERY);
        multiplayerRank.color = ccBLACK;
        [self addChild:multiplayerRank];
        multiplayerRank.opacity = 0;
        
        
        [self scheduleOnce:@selector(fadeInClassic) delay:.25];
        [self scheduleOnce:@selector(fadeInArcade) delay:.75];
        [self scheduleOnce:@selector(fadeInMultiplayer) delay:1.25];
        [self scheduleOnce:@selector(fadeInBot) delay:1.75];
        
        
        //check if player is in game center
        if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            //CLASSIC
            GKLeaderboard *leaderBoard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]];
            leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderBoard.category = @"victorzhougames.webs.com.ClassicLeaderboard";
            
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
                             //__block NSUInteger numScores = 1;
                             [l loadScoresWithCompletionHandler:^(NSArray *scores2, NSError *error2)
                              {
                                  //   NSLog(@"score count: %d", scores.count);
                                  // numScores = scores.count;
                                  [classicRank setString:[NSString stringWithFormat:@"Classic Leaderboard Rank: #%d out of %d players", scoregk.rank, l.maxRange]];
                              }];
                             //NSLog(@"numScores: %d", numScores);
                             
                             
                             return;
                         }
                     }
                 }
                 
             }];
            
            //ARCADE
            leaderBoard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]];
            leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderBoard.category = @"victorzhougames.webs.com.ArcadeLeaderboard";
            
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
                             l.category = @"victorzhougames.webs.com.ArcadeLeaderboard";
                             //__block NSUInteger numScores = 1;
                             [l loadScoresWithCompletionHandler:^(NSArray *scores2, NSError *error2)
                              {
                                  //   NSLog(@"score count: %d", scores.count);
                                  // numScores = scores.count;
                                  [arcadeRank setString:[NSString stringWithFormat:@"Arcade Leaderboard Rank: #%d out of %d players", scoregk.rank, l.maxRange]];
                              }];
                             //NSLog(@"numScores: %d", numScores);
                             
                             
                             return;
                         }
                     }
                 }
                 
             }];
            
            
            //MULTIPLAYER
            leaderBoard = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]];
            leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderBoard.category = @"com.victorzhougames.webs.MultiplayerLeaderboard";
            
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
                             l.category = @"com.victorzhougames.webs.MultiplayerLeaderboard";
                             //__block NSUInteger numScores = 1;
                             [l loadScoresWithCompletionHandler:^(NSArray *scores2, NSError *error2)
                              {
                                  //   NSLog(@"score count: %d", scores.count);
                                  // numScores = scores.count;
                                  [multiplayerRank setString:[NSString stringWithFormat:@"Leaderboard Rank: #%d out of %d players", scoregk.rank, l.maxRange]];
                              }];
                             //NSLog(@"numScores: %d", numScores);
                             
                             
                             return;
                         }
                     }
                 }
                 
             }];
        }

        
        
        
    }
    return self;
}

-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}

-(void)fadeInClassic
{
    [classic runAction:[CCFadeIn actionWithDuration:.75]];
    [classicRank runAction:[CCFadeIn actionWithDuration:.75]];
}
-(void)fadeInArcade
{
    [arcadeRank runAction:[CCFadeIn actionWithDuration:.75]];
    [arcade runAction:[CCFadeIn actionWithDuration:.75]];
}
-(void)fadeInMultiplayer
{
    [multiplayerRank runAction:[CCFadeIn actionWithDuration:.75]];
    [multiplayer runAction:[CCFadeIn actionWithDuration:.75]];
}
-(void)fadeInBot
{
    [gamesPlayed runAction:[CCFadeIn actionWithDuration:.75]];
    [combo runAction:[CCFadeIn actionWithDuration:.75]];
}

@end
