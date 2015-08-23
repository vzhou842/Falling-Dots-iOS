//
//  GeorgeQiLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 7/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "Dot.h"

//COLORS
#define BLACK 200
#define RED 201
#define BLUE 202
#define GREEN 203
#define PURPLE 204
#define POWERUP_1 205
#define POWERUP_2 206
#define POWERUP_3 207
#define GIANT 208


#define TAP_THRESHOLD 100

#define ANDREW_JIN_MODE 402


@interface GeorgeQiLayer : GameLayer {
    
    CCLabelTTF *georgeMode;
}

+(CCScene *) sceneForMode:(int)m;


@end
