//
//  CreditsLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 7/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define JINZ_THRESHOLD 9
#define GEORGE_THRESHOLD 10

@interface CreditsLayer : CCLayer {
    
    CCSprite *background;
    CCSprite *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCLabelTTF *createdBy;
    CCLabelTTF *victorZhou;
    
    CCLabelTTF *notableContributors;
    CCLabelTTF *listNotable;
    
    CCLabelTTF *thanks;
    CCLabelTTF *listThanks;
    
    CCLabelTTF *sponsors;
    
    CCMenuItemImage *amplifinderImage;
    CCMenuItemLabel *francis, *swansoft, *IKS;
    CCMenu *sponsorMenu;
    
    
    
    CGPoint anchorPoint;
    CGPoint startPoint, startAnchorPoint;
    
    int jinzTaps;
    int georgeTaps;
}

+(CCScene *)scene;

-(void)back;

-(void)fadeInTop;
-(void)fadeInMid;
-(void)fadeInBot;
-(void)fadeInSponsors;

-(void)jinz;
-(void)george;


-(void)amplifind;
-(void)francis;
-(void)swansoft;


-(void)updateForAnchorPoint;
@end
