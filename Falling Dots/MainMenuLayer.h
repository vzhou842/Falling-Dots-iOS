//
//  MainMenuLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKit/GameKit.h"
#import "Particle.h"
#import "Dot.h"
#import "AdColony/AdColony.h"

//COLORS
#define BLACK 200
#define RED 201
#define BLUE 202
#define GREEN 203
#define PURPLE 204

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401

//CURRENT MENU
#define MAIN_MENU 900
#define PLAY_SUBMENU 901
#define STATS_SUBMENU 902
#define MORE_SUBMENU 903

//SKINS
#define SKINS_DEFAULT 80
#define SKINS_SQUARE 81
#define SKINS_DIAMOND 82
#define SKINS_STAR 83

#define MENU_SKINS_DEFAULT 90
#define MENU_SKINS_BLACK 91
#define MENU_SKINS_BLUE 92
#define MENU_SKINS_GREEN 93

@interface MainMenuLayer : CCLayer <GKLeaderboardViewControllerDelegate, UIAlertViewDelegate> {
    
    CCSprite *background;
    //CCSprite *backgroundOver;
    CCSprite *falling, *dots;
    
    CCMenu *classicMenu, *arcadeMenu, *multiplayerMenu, *challengesMenu, *leaderboardsMenu, *instructionsMenu, *backMenu, *playMenu, *statsMenu, *personalStatsMenu, *creditsMenu, *upgradesMenu, *shopMenu, *moreMenu, *settingsMenu, *freePointsMenu;
    CCMenuItemImage *classic, *arcade, *multiplayer, *challenges, *leaderboards, *instructions, *back, *play, *stats, *personalStats, *credits, *upgrades, *shop, *more, *settings, *freePoints;
    
    NSMutableArray *particlesArray;
    
    
    NSMutableArray *dotsArray, *dotExplosionsArray;
    
    float currentAvgDensity;
    float currentAvgBaseSpeed;
    NSDate *nextDotCreateDate;
    float elapsedTime;
    
    int currentMenu;
}
@property(nonatomic, retain) NSDate *nextDotCreateDate;

+(CCScene *) scene;

-(void)classic;
-(void)arcade;
-(void)multiplayer;
-(void)challenges;
-(void)instructions;
-(void)back;
-(void)play;
//-(void)stats;
-(void)personalStats;
-(void)credits;
-(void)upgrades;
-(void)shop;
-(void)more;
-(void)settings;
-(void)freePoints;

-(void)transitionOutMain;
-(void)transitionInMain;
-(void)transitionOutPlay;
-(void)transitionInPlay;
//-(void)transitionOutStats;
//-(void)transitionInStats;
-(void)transitionInMore;
-(void)transitionOutMore;

-(void)update;
-(void)createDustFalling;
-(void)createDustDots;
-(void)createMissedTapParticles:(CGPoint)p;
-(CCSprite *)createDotExplosion:(Dot *)d;
-(void)removeDot:(Dot *)d;

//[cctouches stuff here]


-(void)showLeaderboards;


@end
