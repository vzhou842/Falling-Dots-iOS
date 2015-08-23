//
//  IntroLayer.h
//  Falling dotExplosions
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface IntroLayer : CCLayer
{
    CCSprite *dot1, *dot2, *dot3, *dot4, *dot5;
    int numUpdates;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)startScaling;

-(void) makeTransition:(ccTime)dt;
@end