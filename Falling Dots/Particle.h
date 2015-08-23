//
//  Particle.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Particle : NSObject
{
    CCSprite *mySprite;
    CCLayer *myLayer;
    CGPoint v, a;
    NSDate *endDate;
    float duration;
    float dScale, dOpacity;
    
    CGPoint startPos, startV;
    float startScale, startOpacity;
}
@property(nonatomic, retain) CCSprite *mySprite;
@property(readwrite) CGPoint v, a;
@property(nonatomic, retain) NSDate *endDate;

-(Particle *)initWithFileName:(NSString *)file atPoint:(CGPoint)p withV:(CGPoint)vel withA:(CGPoint)acc withDScale:(float)dS withDOpacity:(float)dO withDuration:(float)t forLayer:(CCLayer *)layer;
-(bool)update;
@end
