//
//  InstructionsLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Particle.h"

#define NUM_PAGES 5

#define MIN_MOVE_FOR_SWIPE 25

@interface InstructionsLayer : CCLayer {
    
    CCSprite *background, *top;
    
    CCSprite *currentInstruction, *nextInstruction;
    
    
    CCMenu *backMenu;
    CCMenuItemImage *back;
    
    CCMenu *changeMenu;
    CCMenuItemImage *previous, *next;
    
    int currentInstructionNum;
    
    
    NSMutableArray *particlesArray;
    
    CCMenu *circlesMenu;
    NSMutableArray *circlesArray;
    
    bool instructionIsFalling;
    
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

-(void)showInstruction1;
-(void)showInstruction:(int)n;

-(void)updateParticles;
-(void)createDustDots;
@end
