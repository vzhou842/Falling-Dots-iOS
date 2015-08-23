//
//  IntroLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "MainMenuLayer.h"
#import "TutorialLayer1.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        NSString *fileName = @"Default.png";
        if(result.height == 568)
        {
            fileName = @"Default-568h@2x.png";
        }
        background = [CCSprite spriteWithFile:fileName];
    } else {
        background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
    }
    background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
    // start scaling arrow
    [self scheduleOnce:@selector(startScaling) delay:.5];
    
	// transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1.6];
}
-(void)startScaling
{
    dot1 = [CCSprite spriteWithFile:@"splashScreen_dots.png"];
    dot2 = [CCSprite spriteWithFile:@"splashScreen_dots.png"];
    dot3 = [CCSprite spriteWithFile:@"splashScreen_dots.png"];
    dot4 = [CCSprite spriteWithFile:@"splashScreen_dots.png"];
    dot5 = [CCSprite spriteWithFile:@"splashScreen_dots.png"];
    dot1.scale = 40/600;
    dot2.scale = 40/600;
    dot3.scale = 40/600;
    dot4.scale = 40/600;
    dot5.scale = 40/600;
    dot1.position = ccp(115, 248+OFFSETY);
    dot2.position = ccp(160, 285+OFFSETY);
    dot3.position = ccp(205, 248+OFFSETY);
    dot4.position = ccp(186, 197+OFFSETY);
    dot5.position = ccp(134, 197+OFFSETY);
    [self addChild:dot1];
    [self addChild:dot2];
    [self addChild:dot3];
    [self addChild:dot4];
    [self addChild:dot5];
    /*[dot1 runAction:[CCScaleTo actionWithDuration:1.5 scale:1]];
    [dot2 runAction:[CCScaleTo actionWithDuration:1.5 scale:1]];
    [dot3 runAction:[CCScaleTo actionWithDuration:1.5 scale:1]];
    [dot4 runAction:[CCScaleTo actionWithDuration:1.5 scale:1]];
    [dot5 runAction:[CCScaleTo actionWithDuration:1.5 scale:1]];*/
    [self schedule:@selector(updateScales) interval:1/60.0];
    numUpdates = 0;
    
}

-(void)updateScales
{
    numUpdates++;
    dot1.scale += .005+numUpdates*.002;
    dot2.scale += .005+numUpdates*.002;
    dot3.scale += .005+numUpdates*.002;
    dot4.scale += .005+numUpdates*.002;
    dot5.scale += .005+numUpdates*.002;
}
-(void) makeTransition:(ccTime)dt
{
    //check if this player has ever done the tutorial
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPlayedBefore"])
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0 scene:[TutorialLayer1 scene] withColor:ccWHITE]];
    else
      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
}
@end
