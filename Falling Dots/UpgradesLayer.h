//
//  UpgradesLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "StoreKit/StoreKit.h"
#import "AdColony/AdColony.h"

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401

@interface UpgradesLayer : CCLayer <SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    
    CCSprite *background;
    CCSprite *top;
    CCSprite *bars;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCLabelTTF *dotPointsSpendable;
    
    CCMenu *plusMenu;
    CCMenuItemImage *plus1, *plus2, *plus3, *plus4, *plus5;
    
    CCSprite *bar1, *bar2, *bar3, *bar4, *bar5;
    
    
    int score, gameMode, combo;
    int playerScore, enemyScore;    
    bool fromMainMenu;
    bool fromMultiplayer;
    bool disconnect;
    
    
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
    
    int DPinitial, DPgained;
    bool hasUpdatedDotPoints;
    int numUpdateDPLoops;

}

+(CCScene *)sceneWithScore:(int)s combo:(int)c forMode:(int)mode fromMainMenu:(bool)flag;
+(CCScene *)sceneFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDisconnect:(bool)dc;

-(id)initWithScore:(int)s combo:(int)c forMode:(int)mode fromMainMenu:(bool)flag;
-(id)initFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDisconnect:(bool)dc;

-(void)barsFadeIn;
-(void)scaleBars;

-(void)plus1;
-(void)plus2;
-(void)plus3;
-(void)plus4;
-(void)plus5;

-(void)back;

-(void)updateDotPoints;
-(void)updateDotPointsLoop;

-(void)updatePlusSigns;
-(int)barVal:(int)n;
-(void)setBarValTo:(int)val for:(int)n;
-(int)dotPoints;
-(void)setDotPoints:(int)n;
@end
