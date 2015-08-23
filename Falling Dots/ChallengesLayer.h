//
//  ChallengesLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 6/25/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define NUM_PAGES_CHALLENGES 6

#define MIN_MOVE_FOR_SWIPE 25


@interface ChallengesLayer : CCLayer
{
    CCSprite *background;
    CCSprite *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCMenu *changeMenu;
    CCMenuItemImage *previous, *next;
    
    CCMenu *circlesMenu;
    NSMutableArray *circlesArray;
    
    NSMutableArray *particlesArray;
    
    NSMutableArray *namesArray;
    NSMutableArray *descriptionsArray;
    NSMutableArray *rewardsArray;
    int rewardValues[18];
    
    int currentPageNum;
    
    CCSprite *currentChallenge_bot, *currentChallenge_mid, *currentChallenge_top;
    CCLabelTTF *label_bot, *label_mid, *label_top, *title_bot, *title_mid, *title_top;
    
    int showPage_n;
    
    bool pageIsFalling;
    
    CGPoint dragStart;
    CGPoint previousPoint;
    bool isSwiping;
    bool hasStartedMoving;
    bool isMovingRight;
}

+(CCScene *)scene;

-(void)back;
-(void)previous;
-(void)next;

-(void)updateParticles;
-(void)createDustDotsBot;
-(void)createDustDotsMid;
-(void)createDustDotsTop;
-(void)createClaimRewards:(int)which; //0 = bot, 2 = top

-(void)showPage1;
-(void)showPage:(int)n;
-(void)finishShowPage;
-(void)enableChange;

-(void)claimTop;
-(void)claimMid;
-(void)claimBot;

-(int)dotPoints;
-(void)setDotPoints:(int)n;
@end
