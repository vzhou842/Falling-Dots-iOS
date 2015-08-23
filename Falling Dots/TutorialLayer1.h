//
//  TutorialLayer1.h
//  Falling Dots
//
//  Created by Victor Zhou on 6/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TutorialLayer1 : CCLayer {
    CCSprite *background;
    
    CCSprite *dot;
    
    CCSprite *top;
    
    CCMenu *readyMenu;
    CCMenuItemImage *ready;
} 

+(CCScene *) scene;

-(void)animateIn;
-(void)fadeInDot;
-(void)ready;
@end
