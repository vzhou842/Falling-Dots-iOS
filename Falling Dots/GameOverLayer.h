//
//  GameOverLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKit/GameKit.h"
#import "StoreKit/StoreKit.h"
//#import "Notification.h"

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401
#define ANDREW_JIN_MODE 402
#define GEORGE_QI_MODE 403
#define MULTIPLAYER_MODE 404

#define YPOS_SCORES CENTERY*1.4
#define YPOS_ROUNDMODE YPOS_SCORES+60



@interface GameOverLayer : CCLayer <SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    
    int gameMode;
    
    int drg; //dot rating gained
    
    bool withAnimations;
    
    int timeMultiplier;
    
    CCSprite *background;
    CCSprite *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCMenu *spendMenu;
    CCMenuItemImage *spend;
    
    CCMenu *playAgainMenu;
    CCMenuItemImage *playAgain;
    
    CCLabelTTF *roundMode, *thisRoundScore, *bestScore, *bestCombo, *dotPointsEarned, *dotPointsSpendable;
    CCLabelTTF *particle_dotPoints, *particle_dotRating;
    int num_particle_dotPoints;
    CCSprite *background_best, *background_roundMode, *background_thisRound, *background_combo;
    
    CCMenu *moreDotsMenu;
    CCMenuItemImage *moreDots;
    
    bool isInIAP;
    CCSprite *faded75;
    CCSprite *background_IAP;
    CCSprite *IAP_loading;
    CCMenu *IAPmenu;
    CCMenuItemImage *buy200, *buy500;
    CCMenu *IAPcloseMenu;
    CCMenuItemImage *close;
    
    int score;
    int DPinitial, DPgained;
    bool hasUpdatedDotPoints;
    int numUpdateDPLoops;
    NSMutableArray *particlesArray;

    int combo;
}

- (void)reportScore:(int)s;

+(CCScene *) sceneWithScore:(int)s combo:(int)c forMode:(int)mode withAnimations:(bool)flag;
+(CCScene *) sceneFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDotRatingGain:(int)drg withAnimations:(bool)flag withDisconnect:(bool)dc;

-(id)initWithScore:(int)s combo:(int)c forMode:(int)mode withAnimations:(bool)flag;
-(id)initFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDotRatingGain:(int)dotrg withAnimations:(bool)flag withDisconnect:(bool)dc;

-(void)addDotPointsLabels;
-(void)addSignificantEvent;
-(void)updateParticles;
-(void)spend;
-(void)playAgain;


-(void)updateDotPoints;
-(void)updateDotPointsLoop;
/*-(void)createDPexplosionSmall;
-(void)createDPexplosionBig;*/

-(void)makeMultiplayerParticles;
-(void)removeMultiplayerParticles;
-(void)makeDotPointsGainedParticles;
-(void)removeMakeDotPointsGainedParticles;

-(void)createDustThisRound;
-(void)createDustBestCombo;

-(void)back;

-(void)moreDots;
-(void)buy200;
-(void)buy500;
-(void)closeIAP;

-(int)bestScore;
-(void)setBestScore:(int)n;
-(int)dotPoints;
-(void)setDotPoints:(int)n;
-(int)dotRating;
-(void)setDotRating:(int)n;
@end
