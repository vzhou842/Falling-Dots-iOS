//
//  StatsLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 7/7/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKit/GameKit.h"
#import "StoreKit/StoreKit.h"

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401

@interface StatsLayer : CCLayer {
    
    CCSprite *background, *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCLabelTTF *gamesPlayed, *classic, *arcade, *multiplayer, *combo, *classicRank, *arcadeRank, *multiplayerRank;
}

+(CCScene *) scene;

-(void)back;

@end
