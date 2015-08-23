//
//  GameLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
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

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401
#define ANDREW_JIN_MODE 402
#define GEORGE_QI_MODE 403


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




@interface GameLayer : CCLayer {
    
    NSDate *startDate, *lastUpdateTime;
    NSDate *pauseStartDate;
    
    CCSprite *background, *pauseBackground;
    CCMenu *topMenu;
    CCMenuItemImage *topMenuLeft, *topMenuRight;
    CCSprite *multiplierBar;
    CCMenu *multiplierMenu;
    CCMenuItemImage *multiplierMenuSprite;
    CCLabelTTF *multiplierLabel, *comboLabel;
    
    NSMutableArray *dotsArray, *dotExplosionsArray;
    NSMutableArray *particlesArray;
    
    CCMenu *pauseMenu;
    CCMenuItemImage *pause;
    
    CCMenu *pauseScreenMenu;
    CCMenuItem *resume, *restart, *exit;
    
    float currentAvgDensity;
    float currentAvgBaseSpeed;
    NSDate *nextDotCreateDate;
    float elapsedTime;
    
    int gameMode;
    
    CCMenu *scoreMenu;
    float score;
    CCMenuItemLabel *scoreTextLabel, *scoreNumberLabel;
    
    CCMenu *livesMenu;
    float lives;
    CCMenuItemLabel *livesTextLabel, *livesNumberLabel;
    
    
    CCMenuItemImage *item1, *item2, *item3;
    CCMenu *item1Menu, *item2Menu, *item3Menu;
    CCLabelTTF *itemLabel;
    CCLabelTTF *item1Label, *item2Label, *item3Label;
    bool hasRemovedItemImages;
    
    float speedMultiplier_item;
    
    CCMenu *waitMenu;
    CCMenuItemImage *wait;
    CCLabelTTF *countdown3, *countdown2, *countdown1, *countdownGo;
    bool gameHasStarted;
    
    bool gameIsPaused;
    bool gameIsOver;
    
    int multiplier;
    int consecutiveTaps, maxCombo;
    CCSprite *x2, *x3, *x4, *comboBreaker;
    
    CCSprite *powerup3_fade25;
    NSDate *powerup3End;
    bool p3OpacityIncreasing, p3IsActive;
    
}
@property(nonatomic, retain) NSMutableArray *dotsArray, *dotExplosionsArray;
@property(nonatomic, retain) NSDate *nextDotCreateDate, *powerup3End, *startDate, *lastUpdateTime, *pauseStartDate;
@property(readwrite) bool gameIsPaused;

+(CCScene *) sceneForMode:(int)m;

-(id)initForMode:(int)m;

-(void)countdown3Leave;
-(void)countdown2Leave;
-(void)countdown1Leave;
-(void)countdownGoLeave;
-(void)removeCountdowns;
-(void)removeWaitMenu;
-(void)removeItemObjects;
-(void)startGame;
-(void)goToInstructions;

-(void)useItem1;
-(void)useItem2;
-(void)useItem3;

-(void)update;
-(void)updatePowerupFades;

-(void)addScore:(int)num;
-(void)removeLife;
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

//arcade mode stuff
-(void)createFormation;
-(void)createBlast;
-(void)createRainbowBlast;
-(void)createStairs;
-(void)createRainbowStairs;
-(void)createBox;
-(void)createLine;
-(void)createRainbowLine;

-(void)pauseGame;
-(void)resume;
-(void)restart;
-(void)exit;

-(int)barVal:(int)n;
@end
