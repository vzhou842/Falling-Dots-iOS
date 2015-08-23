//
//  Dot.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

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

#define TRAIL_DECREASE_OPACITY_PER_SECOND 160
#define TRAIL_DECREASE_SCALE_PER_SECOND .75
#define TRAIL_CREATE_INTERVAL .1

//SKINS
#define SKINS_DEFAULT 80
#define SKINS_SQUARE 81
#define SKINS_DIAMOND 82
#define SKINS_STAR 83


@interface Dot : NSObject
{
    CCSprite *mySprite;
    CCLayer *myLayer;
    int myColor;
    float speed;
    
    NSMutableArray *myTrails;
    
    NSDate *nextTrailCreateDate;
    
    
    //purples
    NSDate *lastSwitchDate;
    bool isInRedMode;

}
@property(nonatomic, retain) NSMutableArray *myTrails;
@property(nonatomic, retain) CCSprite *mySprite;
@property(readwrite) int myColor;
@property(nonatomic, retain) NSDate *nextTrailCreateDate, *lastSwitchDate;
@property(nonatomic, retain) CCLayer *myLayer;
@property(readwrite) float speed;
@property(readwrite) bool isInRedMode;

+(NSString *)fileNameForColor:(int)c;

-(Dot *)initAtPoint:(CGPoint)point withColor:(int)c withSpeed:(float)s forLayer:(CCLayer *)l;
-(Dot *)initForDot:(Dot *)d forColor:(int)c;

-(bool)update;
-(bool)updateForMainMenu;
@end
