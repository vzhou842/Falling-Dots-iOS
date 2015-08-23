//
//  InstructionsLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "InstructionsLayer.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0


@implementation InstructionsLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	InstructionsLayer *layer = [InstructionsLayer node];
	[scene addChild: layer];
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        self.isTouchEnabled = YES;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        top = [CCSprite spriteWithFile:@"instructions_top.png"];
        top.position = ccp(160, 2*CENTERY+9);
        [self addChild:top];
        [self reorderChild:top z:999];
        [top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
        
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-100,2*CENTERY-21);
        [self addChild:backMenu];
        [self reorderChild:backMenu z:1000];
        [backMenu runAction:[CCMoveTo actionWithDuration:.8 position:CGPointMake(15, 2*CENTERY-21)]];
        
        previous = [CCMenuItemImage itemWithNormalImage:@"instructions_previous.png" selectedImage:@"instructions_previousSelected.png" target:self selector:@selector(previous)];
        next = [CCMenuItemImage itemWithNormalImage:@"instructions_next.png" selectedImage:@"instructions_nextSelected.png" target:self selector:@selector(next)];
        changeMenu = [CCMenu menuWithItems:previous,next,nil];
        [changeMenu alignItemsHorizontallyWithPadding:200];
        changeMenu.position = ccp(160, -12.5);
        [self addChild:changeMenu];
        [self reorderChild:changeMenu z:10];
        [changeMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 12.5)]];
        
        particlesArray = [[NSMutableArray alloc] init];
        [self schedule:@selector(updateParticles) interval:1/30.0];
        
        circlesArray = [[NSMutableArray alloc] init];
        CCMenuItemImage *circle = [CCMenuItemImage itemWithNormalImage:@"instructions_circleDark.png" selectedImage:@"instructions_circleDark.png"];
        [circlesArray addObject:circle];       
        for (int i=1;i<NUM_PAGES;i++)
        {
            circle = [CCMenuItemImage itemWithNormalImage:@"instructions_circleLight.png" selectedImage:@"instructions_circleLight.png"];
            [circlesArray addObject:circle];
        }
        circlesMenu = [CCMenu menuWithArray:circlesArray];
        circlesMenu.position = ccp(160, 12.5);
        [circlesMenu alignItemsHorizontallyWithPadding:10];
        [self addChild:circlesMenu];
        [self reorderChild:circlesMenu z:9999];
        
        [self scheduleOnce:@selector(showInstruction1) delay:.3];
        currentInstructionNum = 1;
    }
    return self;
}

-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


-(void)previous
{
    if (currentInstructionNum > 1) [self showInstruction:currentInstructionNum-1];
}

-(void)next
{
    if (currentInstructionNum < NUM_PAGES) [self showInstruction:currentInstructionNum+1];
}

-(void)showInstruction1
{
    [self showInstruction:1];
}
-(void)showInstruction:(int)n
{
    [changeMenu setEnabled:NO];
    instructionIsFalling = YES;
    if ([[self children] containsObject:currentInstruction])
    {
        //next
        if (n > currentInstructionNum)
        {
            [currentInstruction runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160-800, 0)]];
        }
        //previous
        else
        {
            [currentInstruction runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160+800, 0)]];
        }
    }
    NSString *instructionFile = [NSString stringWithFormat:@"instructions_%d.png", n];
    if (CENTERY > 240) instructionFile = [NSString stringWithFormat:@"instructions_%d-tall.png", n];
    nextInstruction = [CCSprite spriteWithFile:instructionFile];
    nextInstruction.anchorPoint = CGPointMake(.5, 0);
    nextInstruction.position = ccp(160, 2*CENTERY);
    [self addChild:nextInstruction];
    [nextInstruction runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 0)]];
    [self scheduleOnce:@selector(createDustDots) delay:.3];
    [self scheduleOnce:@selector(finishShowInstructions) delay:.3];
    
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentInstructionNum-1] setNormalImage:[CCSprite spriteWithFile:@"instructions_circleLight.png"]];
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentInstructionNum-1] setSelectedImage:[CCSprite spriteWithFile:@"instructions_circleLight.png"]];
    
    currentInstructionNum = n;
    
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentInstructionNum-1] setNormalImage:[CCSprite spriteWithFile:@"instructions_circleDark.png"]];
    [(CCMenuItemImage *)[circlesArray objectAtIndex:currentInstructionNum-1] setSelectedImage:[CCSprite spriteWithFile:@"instructions_circleDark.png"]];
    
    
}
-(void)finishShowInstructions
{
    if ([[self children] containsObject:currentInstruction]) [self removeChild:currentInstruction cleanup:YES];
    currentInstruction = nextInstruction;
    [changeMenu setEnabled:YES];
    instructionIsFalling = NO;
}


-(void)updateParticles
{
    NSMutableArray *removesPArray = [[NSMutableArray alloc] init];
    for (Particle *tempP in particlesArray)
    {
        if (![tempP update])
        {
            [removesPArray addObject:tempP];
        }
    }
    [particlesArray removeObjectsInArray:removesPArray];
}


-(void)createDustDots
{
    Particle *temp;
    for (int i=0;i<100;i++)
    {
        float vx, vy;
        vx = -40+80*(arc4random()%1000)/1000.0;
        vy = arc4random()%120;
        temp = [[Particle alloc] initWithFileName:@"particle_dust.png" atPoint:CGPointMake(10+arc4random()%300, -3+arc4random()%7) withV:CGPointMake(vx, vy) withA:CGPointMake(0, -200) withDScale:0 withDOpacity:-254 withDuration:1.25 forLayer:self];
        [particlesArray addObject:temp];
    }
}




-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    dragStart = location;
    previousPoint = location;
    isSwiping = YES;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.x == previousPoint.x) return;
    
    if (isSwiping && !instructionIsFalling)
    {
        float dx = location.x-previousPoint.x;
        
        if (!hasStartedMoving)
        {
            if (dx > 0) isMovingRight = YES;
            else isMovingRight = NO;
        }
        else
        {
            //has started moving, check for going wrong direction
            if (isMovingRight && dx < 0) {isSwiping = NO; return;}
            else if (!isMovingRight && dx > 0) {isSwiping = YES; return;}
        }
        
        
        //check for swiping right
        if (isMovingRight && hasStartedMoving && location.x-dragStart.x >= MIN_MOVE_FOR_SWIPE)
        {
            isSwiping = NO;
            [self previous];
        }
        //swiping left
        else if (!isMovingRight && hasStartedMoving && dragStart.x-location.x >= MIN_MOVE_FOR_SWIPE)
        {
            isSwiping = NO;
            [self next];
        }
    }
    previousPoint = location;
    hasStartedMoving = YES;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    hasStartedMoving = NO;
}
@end
