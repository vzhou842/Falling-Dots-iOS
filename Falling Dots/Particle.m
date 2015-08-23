//
//  Particle.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//
//

#import "Particle.h"


@implementation Particle
@synthesize mySprite;
@synthesize v,a;
@synthesize endDate;


-(Particle *)initWithFileName:(NSString *)file atPoint:(CGPoint)p withV:(CGPoint)vel withA:(CGPoint)acc withDScale:(float)dS withDOpacity:(float)dO withDuration:(float)t forLayer:(CCLayer *)layer
{
    if (self = [super init])
    {
        myLayer = layer;
        
        CCSprite *temp = [CCSprite spriteWithFile:file];
        temp.position = p;
        mySprite = temp;
        mySprite.position = p;
        [myLayer addChild:mySprite];
        
        v = vel;
        a = acc;
        
        self.endDate = [NSDate dateWithTimeIntervalSinceNow:t];
        dOpacity = dO;
        dScale = dS;
        duration = t;
        
        startPos = p;
        startV = vel;
        startOpacity = mySprite.opacity;
        startScale = mySprite.scale;
    }
    return self;
}

-(bool)update //return NO if particle expired
{
    mySprite.position = ccp(mySprite.position.x+v.x/30.0, mySprite.position.y+v.y/30.0);
    v = CGPointMake(v.x+a.x/30.0, v.y+a.y/30.0);
    /*mySprite.scale += dScale/(30*duration);
    mySprite.opacity += dOpacity/(30*duration);*/

    float multiplier = (duration-[self.endDate timeIntervalSinceNow])/duration;
    mySprite.scale = startScale+multiplier*dScale;
    mySprite.opacity = startOpacity+multiplier*dOpacity;

    
    if ([[NSDate date] timeIntervalSinceDate:self.endDate] >= 0)
    {
        //remove self, return NO to notify to remove from array
        [myLayer removeChild:mySprite cleanup:YES];
        return NO;
    }
    return YES;
}
@end
