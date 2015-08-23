//
//  GeorgeQiLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 7/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GeorgeQiLayer.h"
#import "GameOverLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation GeorgeQiLayer

+(CCScene *) sceneForMode:(int)m
{
	CCScene *scene = [CCScene node];
	GeorgeQiLayer *layer = [[GeorgeQiLayer alloc] initForMode:m];
	[scene addChild: layer];
	return scene;
}

-(id)initForMode:(int)m
{
    if (self = [super initForMode:m])
    {
        georgeMode = [CCLabelTTF labelWithString:@"Welcome to George Qi Mode" fontName:@"Eurostile" fontSize:22];
        georgeMode.color = ccBLACK;
        georgeMode.position = ccp(160, CENTERY);
        [self addChild:georgeMode];
        [georgeMode runAction:[CCFadeOut actionWithDuration:4]];
        
        [countdown3 setVisible:NO];
        [countdown2 setVisible:NO];
        [countdown1 setVisible:NO];
        [countdownGo setVisible:NO];
        [waitMenu setVisible:NO];
        [waitMenu setEnabled:NO];
        
        currentAvgBaseSpeed /= 20.0;
        currentAvgDensity /= 20.0;
    }
    return self;
}
@end
