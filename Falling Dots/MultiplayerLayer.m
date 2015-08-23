//
//  MultiplayerLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 11/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MultiplayerLayer.h"
#import "MainMenuLayer.h"
#import "AppDelegate.h"
#import "GameOverLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation MultiplayerLayer
@synthesize dotsArray, dotExplosionsArray;
@synthesize nextDotCreateDate, powerup3End, startDate, lastUpdateTime;

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    message.enemyRating = [self dotRating];
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

-(void)sendScore:(float)s
{
    MessageScore message;
    message.message.messageType = kMessageTypeScore;
    message.score = s;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageScore)];
    [self sendData:data];
}

-(void)sendCreateDot:(int)color atPoint:(CGPoint)p withSpeed:(float)s
{
    MessageCreateDot message;
    message.message.messageType = kMessageTypeCreateDot;
    message.color = color;
    message.point = CGPointMake(p.x, p.y);
    message.speed = s;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageCreateDot)];
    [self sendData:data];
}

- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
    [self sendData:data];
    
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
        [self initGameLayer];
    }
    
}

- (void)setGameState:(GameState)state { gameState = state;}



+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	MultiplayerLayer *layer = [MultiplayerLayer node];
	[scene addChild: layer];
	return scene;
}

+(CCScene *)sceneWithInvite
{
    CCScene *scene = [CCScene node];
	MultiplayerLayer *layer = [[MultiplayerLayer alloc] initWithInvite];
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
        
        [self initPreMatchmaking];
        
        
        //rest of game layer prep in -(void)initGameLayer
    }
    return self;
}

-(id)initWithInvite
{
    if (self = [self init])
    {
        [self ranked];
    }
    return self;
}

-(void)openMultiplayer
{
    //MATCHMAKING
    AppController *delegate = (AppController *) [[UIApplication sharedApplication] delegate];
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController delegate:self];
    
    //random #
    ourRandom = arc4random();
    [self setGameState:kGameStateWaitingForMatch];
}

-(void)endGame
{
    [self setGameState:kGameStateDone];
    
    //if ranked, reward for win
    int dotRatingGain = 0;
    if (isRanked)
    {
        //player won
        if (score >= enemyScore)
        {
            [self setDotPoints:[self dotPoints]+30];
            
            //calculate DR gain
            int dx = enemyDotRating-[self dotRating];
            dotRatingGain = (int)(1+(50.0/1000000.0)*pow((500+dx),2));
            if (dx <= -500) dotRatingGain = 1;
            if (dx >= 500) dotRatingGain = 51+(dx-500)/10;
            if (dotRatingGain > 100) dotRatingGain = 100;
            if (dotRatingGain < 1) dotRatingGain = 1;
            [self setDotRating:[self dotRating]+dotRatingGain];
        }
    }
    
    if (isPlayer1) [self sendGameOver:(score >= enemyScore)];
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[GameOverLayer sceneFromMultiplayerWithPlayerScore:score enemyScore:enemyScore withDotRatingGain:dotRatingGain withAnimations:YES withDisconnect:NO] withColor:ccWHITE]];
}

-(void)endGameWithDisconnect
{
    //disconnected
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[GameOverLayer sceneFromMultiplayerWithPlayerScore:score enemyScore:enemyScore withDotRatingGain:0 withAnimations:YES withDisconnect:YES] withColor:ccWHITE]];
}





#pragma mark GCHelperDelegate

- (void)matchStarted {
    CCLOG(@"Match started");
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    if (gameState != kGameStateDone)
        [self endGameWithDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = [playerID retain];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        
        enemyDotRating = messageInit->enemyRating;
        NSLog(@"enemy dot rating: %d", enemyDotRating);
        
        
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            CCLOG(@"We are player 1");
            isPlayer1 = YES;

            
        } else {
            CCLOG(@"We are player 2");
            isPlayer1 = NO;

        }
        
        if (!tie) {
            receivedRandom = YES;
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        
        CCLOG(@"Received Game Begin");
        [self setGameState:kGameStateActive];
        
        
        [self initGameLayer];
        
    }  else if (message->messageType == kMessageTypeScore) {
        
        MessageScore *messageScore = (MessageScore *) [data bytes];
        CCLOG(@"Received Score: %f", messageScore->score);
        
        enemyScore = messageScore->score;
        
        int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
        
        CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)messageScore->score] fontName:@"Eurostile" fontSize:24];
        tempLabel.color = ccBLACK;
        if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
            tempLabel.color = ccWHITE;
        [(CCMenuItemLabel *)[[enemyScoreMenu children] objectAtIndex:1] setLabel:tempLabel];
        [enemyScoreMenu alignItemsHorizontallyWithPadding:10];
        
        //update enemy score bar
        enemyScoreBar.scaleX = 160*(messageScore->score)/500;
        
    } else if (message->messageType == kMessageTypeCreateDot) {
        
        MessageCreateDot *messageCreate = (MessageCreateDot *) [data bytes];
        CCLOG(@"Received Create Dot: color %d, point %f,%f, speed %f", messageCreate->color, messageCreate->point.x, messageCreate->point.y, messageCreate->speed);
        
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(messageCreate->point.x, 2*CENTERY+20) withColor:messageCreate->color withSpeed:messageCreate->speed forLayer:self];
        [dotsArray addObject:tempDot];
        
    } else if (message->messageType == kMessageTypeGameOver) {
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);

        [self endGame];
        
    }
}

- (void)inviteReceived {
    CCLOG(@"invite recieved");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MultiplayerLayer sceneWithInvite] withColor:ccWHITE]];
}

-(void)cancelMatchmaking
{
    NSLog(@"cancelled");
    //enable prematchmaking stuff
    [backMenu setEnabled:YES];
    [rankedMenu setEnabled:YES];
}

-(void)returnToMainMenu
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   P R E - M A T C H M A K I N G    C O D E   /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)initPreMatchmaking
{
    top_pre = [CCSprite spriteWithFile:@"multiplayer_top.png"];
    top_pre.position = ccp(160, 2*CENTERY+9);
    [self addChild:top_pre];
    [self reorderChild:top_pre z:999];
    [top_pre runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
    
    back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
    backMenu = [CCMenu menuWithItems:back, nil];
    backMenu.position = ccp(15-100,2*CENTERY-21);
    [self addChild:backMenu];
    [self reorderChild:backMenu z:1000];
    [backMenu runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(15, 2*CENTERY-21)]];

    ranked = [CCMenuItemImage itemWithNormalImage:@"multiplayer_ranked.png" selectedImage:@"multiplayer_rankedSelected.png" target:self selector:@selector(ranked)];
    rankedMenu = [CCMenu menuWithItems:ranked, nil];
    rankedMenu.position = ccp(160, CENTERY+35);
    [self addChild:rankedMenu];
    rankedMenu.opacity = 0;

    rankedDescription = [CCLabelTTF labelWithString:@"Winner gets 30 Dot Points" fontName:@"Eurostile" fontSize:14];
    rankedDescription.position = ccp(160, rankedMenu.position.y-36);
    rankedDescription.color = ccBLACK;
    [self addChild:rankedDescription];
    rankedDescription.opacity = 0;
    
    yourInfo = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Your Dot Rating: %d", [self dotRating]] fontName:@"Eurostile" fontSize:24];
    yourInfo.position = ccp(160, CENTERY*0.3);
    yourInfo.color = ccBLACK;
    [self addChild:yourInfo];
    yourInfo.opacity = 0;
    
    [self scheduleOnce:@selector(fadeInPreMatchmaking) delay:.3];
    
}

-(void)fadeInPreMatchmaking
{
    [rankedMenu runAction:[CCFadeIn actionWithDuration:.5]];
    [rankedDescription runAction:[CCFadeIn actionWithDuration:.5]];
    [yourInfo runAction:[CCFadeIn actionWithDuration:.5]];
}

-(void)removePreMatchmaking
{
    [self removeChild:top_pre cleanup:YES];
    [self removeChild:backMenu cleanup:YES];
    [self removeChild:rankedMenu cleanup:YES];
    [self removeChild:rankedDescription cleanup:YES];
    [self removeChild:yourInfo cleanup:YES];
}

-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}

-(void)ranked
{
    //disable prematchmaking stuff
    //[backMenu setEnabled:NO];
    //[rankedMenu setEnabled:NO];

    [self openMultiplayer];
    isRanked = YES;
}


-(int)dotPoints
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotPoints"];
}
-(void)setDotPoints:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotPoints"];
}

-(int)dotRating
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotRating"];
}
-(void)setDotRating:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotRating"];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   G A M E    L A Y E R    C O D E   ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)initGameLayer
{
    [self removePreMatchmaking];
    
    self.isTouchEnabled = YES;
    
    NSString *fName, *bName;
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
    if (skin == MENU_SKINS_BLACK) {fName = @"game_multiplayerMenuBlack.png"; bName = @"game_multiplayerMenuBarBlack.png";}
    else if (skin == MENU_SKINS_BLUE) {fName = @"game_multiplayerMenuBlue.png";bName = @"game_multiplayerMenuBarBlue.png";}
    else if (skin == MENU_SKINS_GREEN) {fName = @"game_multiplayerMenuGreen.png";bName = @"game_multiplayerMenuBarGreen.png";}
    else {fName = @"game_multiplayerMenu.png";bName = @"game_multiplayerMenuBar.png";}
    
    top = [CCMenuItemImage itemWithNormalImage:fName selectedImage:fName];
    topMenu = [CCMenu menuWithItems:top, nil];
    topMenu.position = ccp(160, 2*CENTERY-20+80);
    [topMenu alignItemsHorizontallyWithPadding:100];
    [self addChild:topMenu];
    [self reorderChild:topMenu z:INF+3];
    [topMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(160, 2*CENTERY-20)]];
    
    scoreBar = [CCSprite spriteWithFile:bName];
    enemyScoreBar = [CCSprite spriteWithFile:bName];
    scoreBar.anchorPoint = CGPointMake(0, .5);
    enemyScoreBar.anchorPoint = CGPointMake(1, .5);
    scoreBar.position = ccp(0, 2*CENTERY-20+80);
    enemyScoreBar.position = ccp(320, 2*CENTERY-20+80);
    [self addChild:scoreBar];
    [self addChild:enemyScoreBar];
    [self reorderChild:scoreBar z:INF+3];
    [self reorderChild:enemyScoreBar z:INF+3];
    [scoreBar runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(0, 2*CENTERY-20)]];
    [enemyScoreBar runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(320, 2*CENTERY-20)]];
    
    
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
    currentAvgBaseSpeed = INITIAL_AVG_BASE_SPEED;
    self.nextDotCreateDate = [NSDate date];
    elapsedTime = 0;
    
    //score
    score = 0;
    enemyScore = 0;
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
    scoreMenu.position = ccp(80, CENTERY*2-19+80);
    [self addChild:scoreMenu];
    [self reorderChild:scoreMenu z:INF+4];
    [scoreMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(55, CENTERY*2-19)]];
    
    CCLabelTTF *textLabel2, *numberLabel2;
    NSString *text = @"Enemy";
    
    textLabel2 = [CCLabelTTF labelWithString:text fontName:@"Eurostile" fontSize:13];
    textLabel2.color = ccBLACK;
    numberLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)enemyScore] fontName:@"Eurostile" fontSize:24];
    numberLabel2.color = ccBLACK;
    if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
    {
        textLabel2.color = ccWHITE;
        numberLabel2.color = ccWHITE;
    }
    enemyScoreTextLabel = [CCMenuItemLabel itemWithLabel:textLabel2];
    enemyScoreNumberLabel = [CCMenuItemLabel itemWithLabel:numberLabel2];
    enemyScoreMenu = [CCMenu menuWithItems:enemyScoreTextLabel, enemyScoreNumberLabel, nil];
    [enemyScoreMenu alignItemsHorizontallyWithPadding:10];
    enemyScoreMenu.position = ccp(240, CENTERY*2-19+80);
    [self addChild:enemyScoreMenu];
    [self reorderChild:enemyScoreMenu z:INF+4];
    [enemyScoreMenu runAction:[CCMoveTo actionWithDuration:.6 position:CGPointMake(265, CENTERY*2-19)]];
    
    
    //countdown---
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
    
    //objective
    objective = [CCLabelTTF labelWithString:@"First to 500 points wins!" fontName:@"Eurostile" fontSize:24];
    objective.position = ccp(160, 200-500);
    objective.color = ccBLACK;
    [self addChild:objective];
    [objective runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(160, 200)]];
    
    //your vs enemy dot rating
    you = [CCLabelTTF labelWithString:@"You" fontName:@"Eurostile" fontSize:16];
    enemy = [CCLabelTTF labelWithString:@"Enemy" fontName:@"Eurostile" fontSize:16];
    yourDR = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Dot Rating: %d", [self dotRating]] fontName:@"Eurostile" fontSize:14];
    enemyDR = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Dot Rating: %d", enemyDotRating] fontName:@"Eurostile" fontSize:14];
    you.position = ccp(80, CENTERY*3/2+500);
    enemy.position = ccp(240, CENTERY*3/2+500);
    yourDR.position = ccp(you.position.x, you.position.y-15);
    enemyDR.position = ccp(enemy.position.x, enemy.position.y-15);
    you.color = ccBLACK;
    enemy.color = ccBLACK;
    yourDR.color = ccBLACK;
    enemyDR.color = ccBLACK;
    [self addChild:you];
    [self addChild:enemy];
    [self addChild:yourDR];
    [self addChild:enemyDR];
    [you runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(80, CENTERY*3/2)]];
    [enemy runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(240, CENTERY*3/2)]];
    [yourDR runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(you.position.x, CENTERY*3/2-15)]];
    [enemyDR runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(enemy.position.x, CENTERY*3/2-15)]];
    
    
    [self schedule:@selector(update) interval:1/30.0];
    [self schedule:@selector(updatePowerupFades) interval:1/30.0];
    
    
    multiplier = 1;
    consecutiveTaps = 0;

}


//----COUNTDOWN STUFF---
-(void)countdown3Leave
{[countdown3 runAction:[CCFadeOut actionWithDuration:.2]];}
-(void)countdown2Leave
{[countdown2 runAction:[CCFadeOut actionWithDuration:.2]];}
-(void)countdown1Leave
{[countdown1 runAction:[CCFadeOut actionWithDuration:.2]];}
-(void)countdownGoLeave
{[countdownGo runAction:[CCFadeOut actionWithDuration:.2]];}
-(void)removeCountdowns
{
    [self removeChild:countdown3 cleanup:YES];
    [self removeChild:countdown2 cleanup:YES];
    [self removeChild:countdown1 cleanup:YES];
    [self removeChild:countdownGo cleanup:YES];
}
-(void)removeObjective {[self removeChild:objective cleanup:YES];}
-(void)removeDRs
{
    [self removeChild:you cleanup:YES];
    [self removeChild:enemy cleanup:YES];
    [self removeChild:yourDR cleanup:YES];
    [self removeChild:enemyDR cleanup:YES];
}
-(void)startGame
{
    gameHasStarted = YES;
    [self scheduleOnce:@selector(removeCountdowns) delay:.5];

    //times
    self.startDate = [NSDate date];
    self.lastUpdateTime = [NSDate date];
    
    //objective
    [objective runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(160, 200-500)]];
    [self scheduleOnce:@selector(removeObjective) delay:1];
    
    //your vs enemy dot rating
    [you runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(you.position.x, you.position.y+500)]];
    [enemy runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(enemy.position.x, enemy.position.y+500)]];
    [yourDR runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(yourDR.position.x, yourDR.position.y+500)]];
    [enemyDR runAction:[CCMoveTo actionWithDuration:1 position:CGPointMake(enemyDR.position.x, enemyDR.position.y+500)]];
    [self scheduleOnce:@selector(removeDRs) delay:1];

}


// ----------- UPDATE -------------
-(void)update
{
    if (!gameHasStarted) return;
    
    //check for game over
    if (isPlayer1 && gameState != kGameStateDone && (score >= 500 || enemyScore >= 500))
    {
        [self endGame];
    }
    
    //elapsedTime += 1/30.0000;
    elapsedTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
    
    //-------------DOTS-------------
    
    //update avg density and avg speed
    if (currentAvgBaseSpeed < MAX_SPEED) //cutoff at max speed
        currentAvgBaseSpeed += (SPEED_INCREASE_PER_SECOND/30.0);
    currentAvgDensity += (DENSITY_INCREASE_PER_SECOND/30.0)*((elapsedTime >= DIFF_INC_PLATEAU_TIME)
                                                                 ?DIFF_INC_MIN_MULTIPLIER
                                                                 :(1-(1-DIFF_INC_MIN_MULTIPLIER)*elapsedTime/DIFF_INC_PLATEAU_TIME));
    
    
    //creating dots-------- ONLY FOR PLAYER 1
    if (gameState != kGameStateDone && isPlayer1 && [[NSDate date] timeIntervalSinceDate:self.nextDotCreateDate] >= 0)
    {
        //location
        float x = 10+arc4random()%300;
        //color-----
        int color = arc4random()%1000;
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
        
        //4% chance of powerup, 5% late game
        if (arc4random()%1000 < ((elapsedTime>40)?50:40))
        {
            int which = arc4random()%1000;
            if (which < 250) color = POWERUP_1;
            else if (which < 750) color = POWERUP_2;
            else color = POWERUP_3;
        }
        
        //speed
        float speed = currentAvgBaseSpeed*.85 + .3*currentAvgBaseSpeed*(arc4random()%1000)/1000.0;
        if (color == GREEN) speed *= 1.75;
        if (color == PURPLE) speed *= .6;
        if (color == POWERUP_1 || color == POWERUP_2 || color == POWERUP_3) speed *= .65;
        
        //send notif to player 2
        [self sendCreateDot:color atPoint:CGPointMake(x, 2*CENTERY+20) withSpeed:speed];
        
        //create dot
        Dot *tempDot = [[Dot alloc] initAtPoint:CGPointMake(x, 2*CENTERY+20) withColor:color withSpeed:speed forLayer:self];
        [dotsArray addObject:tempDot];
        
        //set next time for creating dotA

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
    if (gameState == kGameStateDone) return;
    
    if (!gameHasStarted) return;
    
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
        if (closestDistanceSqr <= 32*32)
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

                    [self addScore:-1];
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
            [self resetMultiplier];
            [self createMissedTapParticles:location];
        }
    }
    else
    {
        [self resetMultiplier];
        [self createMissedTapParticles:location];
    }
}
//-----------------------------------END OF TOUCHES-----------------------------------------------------

-(void)addScore:(int)num
{
    if (num >= 0) //gain score
        score+=multiplier*num*((p3IsActive)?2:1);
    else if (num < 0) //lose score
        score += num;
    
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"];
    
    CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)score] fontName:@"Eurostile" fontSize:24];
    tempLabel.color = ccBLACK;
    if (skin == MENU_SKINS_BLACK || skin == MENU_SKINS_BLUE)
        tempLabel.color = ccWHITE;
    [(CCMenuItemLabel *)[[scoreMenu children] objectAtIndex:1] setLabel:tempLabel];
    [scoreMenu alignItemsHorizontallyWithPadding:10];
    
    //update score bar
    scoreBar.scaleX = 160*(score/500);
    
    //send score update
    if (gameState != kGameStateDone)
        [self sendScore:score];
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
{if ([[self children] containsObject:x2]) [self removeChild:x2 cleanup:YES];}
-(void)removex3
{if ([[self children] containsObject:x3]) [self removeChild:x3 cleanup:YES];}
-(void)removex4
{if ([[self children] containsObject:x4]) [self removeChild:x4 cleanup:YES];}
-(void)removeComboBreaker
{if ([[self children] containsObject:comboBreaker]) [self removeChild:comboBreaker cleanup:YES];}

@end
