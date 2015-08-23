//
//  Dot.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//
//

#import "Dot.h"

@implementation Dot
@synthesize myTrails;
@synthesize mySprite;
@synthesize myColor;
@synthesize nextTrailCreateDate, lastSwitchDate;
@synthesize myLayer;
@synthesize speed;
@synthesize isInRedMode;

+(NSString *)fileNameForColor:(int)c
{
    NSString *spriteFile;
    int skin = [[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_skin"];

    switch (c)
    {
        case BLACK:
            if (skin == SKINS_SQUARE)
                spriteFile = @"dot_blackSquare.png";
            else if (skin == SKINS_DIAMOND)
                spriteFile = @"dot_blackDiamond.png";
            else if (skin == SKINS_STAR)
                spriteFile = @"dot_blackStar.png";
            else
                spriteFile = @"dot_black.png";
            break;
        case BLUE:
            if (skin == SKINS_SQUARE)
                spriteFile = @"dot_blueSquare.png";
            else if (skin == SKINS_DIAMOND)
                spriteFile = @"dot_blueDiamond.png";
            else if (skin == SKINS_STAR)
                spriteFile = @"dot_blueStar.png";
            else
                spriteFile = @"dot_blue.png";
            break;
        case RED:
            if (skin == SKINS_SQUARE)
                spriteFile = @"dot_redSquare.png";
            else if (skin == SKINS_DIAMOND)
                spriteFile = @"dot_redDiamond.png";
            else if (skin == SKINS_STAR)
                spriteFile = @"dot_redStar.png";
            else
                spriteFile = @"dot_red.png";
            break;
        case GREEN:
            if (skin == SKINS_SQUARE)
                spriteFile = @"dot_greenSquare.png";
            else if (skin == SKINS_DIAMOND)
                spriteFile = @"dot_greenDiamond.png";
            else if (skin == SKINS_STAR)
                spriteFile = @"dot_greenStar.png";
            else
                spriteFile = @"dot_green.png";
            break;
        case PURPLE:
            if (skin == SKINS_SQUARE)
                spriteFile = @"dot_purpleSquare.png";
            else if (skin == SKINS_DIAMOND)
                spriteFile = @"dot_purpleDiamond.png";
            else if (skin == SKINS_STAR)
                spriteFile = @"dot_purpleStar.png";
            else
                spriteFile = @"dot_purple.png";
            break;
        case POWERUP_1:
            spriteFile = @"dot_powerup1.png";
            break;
        case POWERUP_2:
            spriteFile = @"dot_powerup2.png";
            break;
        case POWERUP_3:
            spriteFile = @"dot_powerup3.png";
            break;
        case GIANT:
            spriteFile = @"dot_giant.png";
            break;
        default:
            NSLog(@"VALID COLOR NOT SUPPLIED");
            return NULL;
            break;
    }
    return spriteFile;
}

-(Dot *)initAtPoint:(CGPoint)point withColor:(int)c withSpeed:(float)s forLayer:(CCLayer *)l
{
    if (self = [super init])
    {
        NSString *spriteFile = [Dot fileNameForColor:c];
        mySprite = [CCSprite spriteWithFile:spriteFile];
        mySprite.position = point;
        myLayer = l;
        [myLayer addChild:mySprite];
        
        myColor = c;
        
        speed = s;
        
        
        self.myTrails = [[NSMutableArray alloc] init];
        
        self.nextTrailCreateDate = [NSDate date];
        
        self.lastSwitchDate = [NSDate date];
    }
    return self;
}

-(Dot *)initForDot:(Dot *)d forColor:(int)c
{
    if (self = [super init])
    {
        NSString *spriteFile = [Dot fileNameForColor:c];
        mySprite = [CCSprite spriteWithFile:spriteFile];
        mySprite.position = d.mySprite.position;
        myLayer = d.myLayer;
        [myLayer addChild:mySprite];
        
        myColor = c;
        
        speed = d.speed;
        if (c == GREEN) speed *= 1.75;
        
        
        self.myTrails = [[NSMutableArray alloc] init];
        
        self.nextTrailCreateDate = [NSDate date];
        
        self.lastSwitchDate = [NSDate date];
        
        //copy trails
        for (CCSprite *temp in d.myTrails)
        {
            CCSprite *myCopy = [CCSprite spriteWithFile:[Dot fileNameForColor:myColor]];
            myCopy.position = temp.position;
            myCopy.scale = temp.scale;
            myCopy.opacity = temp.opacity;
            [myLayer addChild:myCopy];
            [myTrails addObject:myCopy];
        }
    }
    return self;
}


-(bool)update //returns NO if the dot needs to be removed
{
    //update pos
    mySprite.position = ccp(mySprite.position.x, mySprite.position.y-speed/30.0);
    
    //create trail
    if ([[NSDate date] timeIntervalSinceDate:self.nextTrailCreateDate] >= 0)
    {
        CCSprite *temp;
        //check if purple
        if (myColor == PURPLE)
        {
            temp = [CCSprite spriteWithFile:[Dot fileNameForColor:(isInRedMode)?RED:PURPLE]];
        }
        //not purple
        else
        {
            temp = [CCSprite spriteWithFile:[Dot fileNameForColor:myColor]];
        }
        
        temp.position = (myColor == GIANT)?CGPointMake(mySprite.position.x,mySprite.position.y+20):mySprite.position;
        temp.opacity = 120;
        [myLayer addChild:temp];
        [myTrails addObject:temp];
        self.nextTrailCreateDate = [NSDate dateWithTimeIntervalSinceNow:((myColor == GIANT)?10:1)*TRAIL_CREATE_INTERVAL];
    }
    //update trail
    NSMutableArray *removes = [[NSMutableArray alloc] init];
    for (CCSprite *tempTrail in myTrails)
    {
        //check if we should kill this sprite
        if (tempTrail.opacity <= TRAIL_DECREASE_OPACITY_PER_SECOND/30.0)
        {
            [myLayer removeChild:tempTrail cleanup:YES];
            [removes addObject:tempTrail];
        }
        else
        {
            tempTrail.opacity -= ((myColor == GIANT)?.1:1)*TRAIL_DECREASE_OPACITY_PER_SECOND/30.0;
            tempTrail.scale -= ((myColor == GIANT)?.2:1)*TRAIL_DECREASE_SCALE_PER_SECOND/30.0;
        }
        
    }
    [myTrails removeObjectsInArray:removes];
    
    //PURPLE: check if switch needed
    float purpleMult = [[NSUserDefaults standardUserDefaults] floatForKey:@"purpleItemActive"];
    if (purpleMult < 1) purpleMult = 1;
    if (myColor == PURPLE && ((isInRedMode && [[NSDate date] timeIntervalSinceDate:self.lastSwitchDate] >= .8) || (!isInRedMode && [[NSDate date] timeIntervalSinceDate:self.lastSwitchDate] >= purpleMult*1.6)))
    {
        if (isInRedMode)
        {
            //switch to purple
            mySprite.texture = [[CCSprite spriteWithFile:[Dot fileNameForColor:PURPLE]] texture];
            
            for (CCSprite *temp in myTrails)
            {
                temp.texture = [[CCSprite spriteWithFile:[Dot fileNameForColor:PURPLE]] texture];
            }
        }
        else
        {
            //switch to red
            mySprite.texture = [[CCSprite spriteWithFile:[Dot fileNameForColor:RED]] texture];
            
            for (CCSprite *temp in myTrails)
            {
                temp.texture = [[CCSprite spriteWithFile:[Dot fileNameForColor:RED]] texture];
            }
        }
        isInRedMode = !isInRedMode;
        
        self.lastSwitchDate = [NSDate date];
    }
    
    
    //check if dot needs to be removed
    if (mySprite.position.y < 30)
    {
        return NO;
    }
    return YES;
}

-(bool)updateForMainMenu
{
    bool flag = [self update];
    if (!flag && mySprite.position.y < -20) return NO;
    return YES;
}


@end
