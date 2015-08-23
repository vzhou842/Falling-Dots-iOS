//
//  ShopLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 8/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define NUM_PAGES_SHOP 3

#define MIN_MOVE_FOR_SWIPE 25

@interface ShopLayer : CCLayer {
    
    CCSprite *background;
    CCSprite *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCMenu *changeMenu;
    CCMenuItemImage *previous, *next;
    
    CCMenu *circlesMenu;
    
    CCLabelTTF *dotPoints;
    
    NSMutableArray *circlesArray;
    
    NSMutableArray *particlesArray;
    
    NSMutableArray *namesArray;
    NSMutableArray *descriptionsArray;
    NSMutableArray *costsArray;
    int costValues[9];
    
    int currentPageNum;
    
    CCSprite *currentChallenge_bot, *currentChallenge_mid, *currentChallenge_top;
    CCSprite *currentIcon_bot, *currentIcon_mid, *currentIcon_top;
    CCLabelTTF *label_bot, *label_mid, *label_top, *title_bot, *title_mid, *title_top;
    
    CCMenu *buyTopMenu, *buyMidMenu, *buyBotMenu;
    CCMenuItemImage *buyTop, *buyMid, *buyBot;
    
    int showPage_n;
    
    bool pageIsFalling;
    
    CGPoint dragStart;
    CGPoint previousPoint;
    bool isSwiping;
    bool hasStartedMoving;
    bool isMovingRight;
    
    int DPinitial, DPgained;
    bool hasUpdatedDotPoints;
    int numUpdateDPLoops;
}

+(CCScene *) scene;

-(void)back;
-(void)previous;
-(void)next;

-(void)updateDotPointsRed;
-(void)cantAfford;

-(void)updateParticles;
-(void)createDustDotsBot;
-(void)createDustDotsMid;
-(void)createDustDotsTop;
-(void)createBuyItemDots:(int)which;

-(void)updateIcons;
-(void)showPage1;
-(void)showPage:(int)n;
-(void)finishShowPage;
-(void)enableChange;

-(void)buyTop;
-(void)buyMid;
-(void)buyBot;

-(void)checkCanAfford;

-(int)dotPoints;
-(void)setDotPoints:(int)n;
@end
