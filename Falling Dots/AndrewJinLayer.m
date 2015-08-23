//
//  AndrewJinLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 7/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AndrewJinLayer.h"
#import "GameOverLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation AndrewJinLayer

+(CCScene *) sceneForMode:(int)m
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [[AndrewJinLayer alloc] initForMode:m];
	[scene addChild: layer];
	return scene;
}

-(id)initForMode:(int)m
{
    if (self = [super initForMode:m])
    {
        
        jinzMode = [CCLabelTTF labelWithString:@"Welcome to Andrew Jin Mode" fontName:@"Eurostile" fontSize:22];
        jinzMode.color = ccBLACK;
        jinzMode.position = ccp(160, CENTERY);
        [self addChild:jinzMode];
        [jinzMode runAction:[CCFadeOut actionWithDuration:4]];
        
        [countdown3 setVisible:NO];
        [countdown2 setVisible:NO];
        [countdown1 setVisible:NO];
        [countdownGo setVisible:NO];
        [waitMenu setVisible:NO];
        [waitMenu setEnabled:NO];
        
        dot_giant = [[Dot alloc] initAtPoint:CGPointMake(160, 3*CENTERY) withColor:GIANT withSpeed:25 forLayer:self];
        
        [self schedule:@selector(update) interval:1/30.0];
    }
    return self;
}

-(void)update
{
    if (gameIsPaused) return;
    
     
    //check if off screen
    [dot_giant update];
    if (dot_giant.mySprite.position.y <= -100)
    {
        //lose
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithScore:0 combo:numTaps forMode:ANDREW_JIN_MODE withAnimations:YES] withColor:ccWHITE]];
    }
}



-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if (gameIsPaused) return;
    
    UITouch *touch = [ touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (pow(location.x-dot_giant.mySprite.position.x,2)+pow(location.y-dot_giant.mySprite.position.y,2) <= 100*100)
    {
        numTaps++;
        
        comboLabel.string = [NSString stringWithFormat:@"Combo: %d", numTaps];
        
        //check if tapped enough times
        if (numTaps >= TAP_THRESHOLD)
        {
            //win
            NSLog(@"completed challenge 15");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedChallenge15"];

            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithScore:1 combo:numTaps forMode:ANDREW_JIN_MODE withAnimations:YES] withColor:ccWHITE]];
        }
    }
}

@end
