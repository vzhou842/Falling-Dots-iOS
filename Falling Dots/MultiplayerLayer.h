//
//  MultiplayerLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 11/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCHelper.h"
#import "Dot.h"
#import "Particle.h"


//COLORS
#define BLACK 200
#define RED 201
#define BLUE 202
#define GREEN 203
#define PURPLE 204
#define POWERUP_1 205
#define POWERUP_2 206
#define POWERUP_3 207

#define INF 999999

#define START_LIVES 30
#define START_TIME 100

#define INITIAL_AVG_DENSITY 1.25 //1.25
#define INITIAL_AVG_BASE_SPEED 130*([[CCDirector sharedDirector] winSize].height-80)/400.0 //130

#define DENSITY_INCREASE_PER_SECOND .075
#define SPEED_INCREASE_PER_SECOND .8*([[CCDirector sharedDirector] winSize].height-80)/400.0

#define MAX_SPEED INITIAL_AVG_BASE_SPEED+SPEED_INCREASE_PER_SECOND*120 //120 second cutoff

#define DOTEXPLOSION_DECREASE_ALPHA_PER_SECOND 1000
#define DOTEXPLOSION_INCREASE_SIZE_PER_SECOND 2

#define DIFF_INC_PLATEAU_TIME 125 //difficulty increase
#define DIFF_INC_MIN_MULTIPLIER .2


//SKINS
#define SKINS_DEFAULT 80
#define SKINS_SQUARE 81
#define SKINS_DIAMOND 82
#define SKINS_STAR 83


typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeScore,
    kMessageTypeCreateDot,
    kMessageTypeGameOver
} MessageType;


typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
    int enemyRating;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
    float score;
} MessageScore;

typedef struct {
    Message message;
    int color;
    CGPoint point;
    float speed;
} MessageCreateDot;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;



@interface MultiplayerLayer : CCLayer <GCHelperDelegate> {
    
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
    
    GameState gameState;
    
    bool isPlayer1;
    
    bool hasAlreadySentGameOver;
    
    bool isRanked;
    
    int enemyDotRating;
    
    
    //PRE MATCHMAKING
   
    CCSprite *top_pre;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCMenu *rankedMenu;
    CCMenuItemImage *ranked;
    
    CCLabelTTF *rankedDescription, *yourInfo;
    
    
    
    //GAME LAYER
    NSDate *startDate, *lastUpdateTime;
    
    CCSprite *background;
    CCMenu *topMenu;
    CCMenuItemImage *top;
    CCSprite *scoreBar, *enemyScoreBar;
    CCSprite *multiplierBar;
    CCMenu *multiplierMenu;
    CCMenuItemImage *multiplierMenuSprite;
    CCLabelTTF *multiplierLabel, *comboLabel;
    
    NSMutableArray *dotsArray, *dotExplosionsArray;
    NSMutableArray *particlesArray;
    
    float currentAvgDensity;
    float currentAvgBaseSpeed;
    NSDate *nextDotCreateDate;
    float elapsedTime;
    
    CCMenu *scoreMenu;
    float score;
    CCMenuItemLabel *scoreTextLabel, *scoreNumberLabel;
    
    CCMenu *enemyScoreMenu;
    float enemyScore;
    CCMenuItemLabel *enemyScoreTextLabel, *enemyScoreNumberLabel;
    
    float speedMultiplier_item;

    CCLabelTTF *you, *enemy, *yourDR, *enemyDR;
    CCLabelTTF *countdown3, *countdown2, *countdown1, *countdownGo;
    CCLabelTTF *objective;
    bool gameHasStarted;
    
    bool gameIsOver;
    
    int multiplier;
    int consecutiveTaps, maxCombo;
    CCSprite *x2, *x3, *x4, *comboBreaker;
    
    CCSprite *powerup3_fade25;
    NSDate *powerup3End;
    bool p3OpacityIncreasing, p3IsActive;
    
}
@property(nonatomic, retain) NSMutableArray *dotsArray, *dotExplosionsArray;
@property(nonatomic, retain) NSDate *nextDotCreateDate, *powerup3End, *startDate, *lastUpdateTime;


+(CCScene *)scene;
+(CCScene *)sceneWithInvite;
-(id)init;
-(id)initWithInvite;

-(void)openMultiplayer;


//PRE-MATCHMAKING CODE
-(void)initPreMatchmaking;
-(void)fadeInPreMatchmaking;
-(void)removePreMatchmaking;

-(void)back;
-(void)ranked;

-(int)dotPoints;
-(void)setDotPoints:(int)n;
-(int)dotRating;
-(void)setDotRating:(int)n;

//GAME LAYER CODE
-(void)initGameLayer;

-(void)countdown3Leave;
-(void)countdown2Leave;
-(void)countdown1Leave;
-(void)countdownGoLeave;
-(void)removeCountdowns;
-(void)removeObjective;
-(void)removeDRs;
-(void)startGame;

-(void)update;
-(void)updatePowerupFades;

-(void)addScore:(int)num;
-(void)createPowerup1Particles;
-(void)createPowerup2Particles:(Dot *)d;
-(void)createDotDeathParticles:(Dot *)d;
-(void)createMissedTapParticles:(CGPoint)p;
-(CCSprite *)createDotExplosion:(Dot *)d;
-(void)removeDot:(Dot *)d;

-(void)addConsecutiveTap;
-(void)resetMultiplier;
-(void)createMultiplierParticlesGreen;
-(void)createMultiplierParticlesBlue;
-(void)createMultiplierParticlesPurple;
-(void)removex2;
-(void)removex3;
-(void)removex4;
-(void)removeComboBreaker;
@end
