//
//  SettingsLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 8/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"
#import "MainMenuLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0

@implementation SettingsLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	SettingsLayer *layer = [SettingsLayer node];
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
        
        //top
        top = [CCSprite spriteWithFile:@"settings_top.png"];
        top.position = ccp(160, 2*CENTERY-21+100);
        [self addChild:top];
        [top runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, 2*CENTERY-21)]];
        
        //back
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-300,2*CENTERY-21);
        [self addChild:backMenu];
        [backMenu runAction:[CCMoveTo actionWithDuration:1.5 position:CGPointMake(15, 2*CENTERY-21)]];
        
        //skins---
        skins = [CCLabelTTF labelWithString:@"Skins" fontName:@"Eurostile" fontSize:24];
        skins.position = ccp(160, CENTERY*1.75);
        skins.color = ccBLACK;
        [self addChild:skins];
        skins.opacity = 0;
        
        skins_default = [CCMenuItemImage itemWithNormalImage:@"settings_skin_default.png" selectedImage:@"settings_skin_defaultSelected.png" target:self selector:@selector(skinDefault)];
        if ([self hasItem:7])
            squares = [CCMenuItemImage itemWithNormalImage:@"settings_skin_squares.png" selectedImage:@"settings_skin_squaresSelected.png" target:self selector:@selector(squares)];
        else
            squares = [CCMenuItemImage itemWithNormalImage:@"settings_skin_squaresGrayed.png" selectedImage:@"settings_skin_squaresGrayed.png"];
        if ([self hasItem:8])
            diamonds = [CCMenuItemImage itemWithNormalImage:@"settings_skin_diamonds.png" selectedImage:@"settings_skin_diamondsSelected.png" target:self selector:@selector(diamonds)];
        else
            diamonds = [CCMenuItemImage itemWithNormalImage:@"settings_skin_diamondsGrayed.png" selectedImage:@"settings_skin_diamondsGrayed.png"];
        if ([self hasItem:9])
            stars = [CCMenuItemImage itemWithNormalImage:@"settings_skin_stars.png" selectedImage:@"settings_skin_starsSelected.png" target:self selector:@selector(stars)];
        else
            stars = [CCMenuItemImage itemWithNormalImage:@"settings_skin_starsGrayed.png" selectedImage:@"settings_skin_starsGrayed.png"];
        
        skins_defaultMenu = [CCMenu menuWithItems:skins_default, nil];
        squaresMenu = [CCMenu menuWithItems:squares, nil];
        diamondsMenu = [CCMenu menuWithItems:diamonds, nil];
        starsMenu = [CCMenu menuWithItems:stars, nil];
        skins_defaultMenu.position = ccp(160, CENTERY*1.61);
        squaresMenu.position = ccp(160, CENTERY*1.43);
        diamondsMenu.position = ccp(160, CENTERY*1.25);
        starsMenu.position = ccp(160, CENTERY*1.07);
        [self addChild:skins_defaultMenu];
        [self addChild:squaresMenu];
        [self addChild:diamondsMenu];
        [self addChild:starsMenu];
        skins_defaultMenu.opacity = 0;
        squaresMenu.opacity = 0;
        diamondsMenu.opacity = 0;
        starsMenu.opacity = 0;
        
        if (![self hasItem:7])
        {
            locked7 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked7.color = ccBLACK;
            [self addChild:locked7];
            locked7.position = squaresMenu.position;
            locked7.opacity = 0;
        }
        if (![self hasItem:8])
        {
            locked8 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked8.color = ccBLACK;
            [self addChild:locked8];
            locked8.position = diamondsMenu.position;
            locked8.opacity = 0;
        }
        if (![self hasItem:9])
        {
            locked9 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked9.color = ccBLACK;
            [self addChild:locked9];
            locked9.position = starsMenu.position;
            locked9.opacity = 0;
        }
        
        equipped_skins = [CCSprite spriteWithFile:@"settings_equipped.png"];
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_skin"])
        {
            case SKINS_DEFAULT:
                equipped_skins.position = skins_defaultMenu.position;
                break;
            case SKINS_DIAMOND:
                equipped_skins.position = diamondsMenu.position;
                break;
            case SKINS_SQUARE:
                equipped_skins.position = squaresMenu.position;
                break;
            case SKINS_STAR:
                equipped_skins.position = starsMenu.position;
                break;
            default:
                NSLog(@"INVALID EQUIPPED SKIN");
                equipped_skins.position = skins_defaultMenu.position;
                break;
        }
        [self addChild:equipped_skins];
        equipped_skins.opacity = 0;
        
        [self scheduleOnce:@selector(fadeInSkins) delay:.5];
        
        
        
        //menu skins---
        menuSkins = [CCLabelTTF labelWithString:@"Menu Skins" fontName:@"Eurostile" fontSize:24];
        menuSkins.position = ccp(160, CENTERY*.87);
        menuSkins.color = ccBLACK;
        [self addChild:menuSkins];
        menuSkins.opacity = 0;        
        
        menuSkins_default = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_default.png" selectedImage:@"settings_menuSkin_defaultSelected.png" target:self selector:@selector(menuSkinDefault)];
        if ([self hasItem:4])
            black = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_black.png" selectedImage:@"settings_menuSkin_blackSelected.png" target:self selector:@selector(black)];
        else
            black = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_blackGrayed.png" selectedImage:@"settings_menuSkin_blackGrayed.png"];
        if ([self hasItem:5])
            blue = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_blue.png" selectedImage:@"settings_menuSkin_blueSelected.png" target:self selector:@selector(blue)];
        else
            blue = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_blueGrayed.png" selectedImage:@"settings_menuSkin_blueGrayed.png"];
        if ([self hasItem:6])
            green = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_green.png" selectedImage:@"settings_menuSkin_greenSelected.png" target:self selector:@selector(green)];
        else
            green = [CCMenuItemImage itemWithNormalImage:@"settings_menuSkin_greenGrayed.png" selectedImage:@"settings_menuSkin_greenGrayed.png"];
        
        menuSkins_defaultMenu = [CCMenu menuWithItems:menuSkins_default, nil];
        blackMenu = [CCMenu menuWithItems:black, nil];
        blueMenu = [CCMenu menuWithItems:blue, nil];
        greenMenu = [CCMenu menuWithItems:green, nil];
        menuSkins_defaultMenu.position = ccp(160, CENTERY*.73);
        blackMenu.position = ccp(160, CENTERY*.55);
        blueMenu.position = ccp(160, CENTERY*.37);
        greenMenu.position = ccp(160, CENTERY*.19);
        [self addChild:menuSkins_defaultMenu];
        [self addChild:blackMenu];
        [self addChild:blueMenu];
        [self addChild:greenMenu];
        menuSkins_defaultMenu.opacity = 0;
        blackMenu.opacity = 0;
        blueMenu.opacity = 0;
        greenMenu.opacity = 0;
        
        if (![self hasItem:4])
        {
            locked4 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked4.color = ccBLACK;
            [self addChild:locked4];
            locked4.position = blackMenu.position;
            locked4.opacity = 0;
        }
        if (![self hasItem:5])
        {
            locked5 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked5.color = ccBLACK;
            [self addChild:locked5];
            locked5.position = blueMenu.position;
            locked5.opacity = 0;
        }
        if (![self hasItem:6])
        {
            locked6 = [CCLabelTTF labelWithString:@"Unlock in the Dot Shop" fontName:@"Eurostile" fontSize:12];
            locked6.color = ccBLACK;
            [self addChild:locked6];
            locked6.position = greenMenu.position;
            locked6.opacity = 0;
        }
        
        equipped_menuSkins = [CCSprite spriteWithFile:@"settings_equipped.png"];
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"equipped_menu_skin"])
        {
            case MENU_SKINS_DEFAULT:
                equipped_menuSkins.position = menuSkins_defaultMenu.position;
                break;
            case MENU_SKINS_BLACK:
                equipped_menuSkins.position = blackMenu.position;
                break;
            case MENU_SKINS_BLUE:
                equipped_menuSkins.position = blueMenu.position;
                break;
            case MENU_SKINS_GREEN:
                equipped_menuSkins.position = greenMenu.position;
                break;
            default:
                NSLog(@"INVALID EQUIPPED MENU SKIN");
                equipped_menuSkins.position = menuSkins_defaultMenu.position;
                break;
        }
        [self addChild:equipped_menuSkins];
        equipped_menuSkins.opacity = 0;
        
        [self scheduleOnce:@selector(fadeInMenuSkins) delay:1];
    }
    return self;
}

-(void)fadeInSkins
{
    [skins runAction:[CCFadeIn actionWithDuration:.3]];
    [skins_defaultMenu runAction:[CCFadeIn actionWithDuration:.3]];
    [squaresMenu runAction:[CCFadeIn actionWithDuration:.3]];
    [diamondsMenu runAction:[CCFadeIn actionWithDuration:.3]];
    [starsMenu runAction:[CCFadeIn actionWithDuration:.3]];
    
    if (![self hasItem:7]) [locked7 runAction:[CCFadeIn actionWithDuration:.3]];
    if (![self hasItem:8]) [locked8 runAction:[CCFadeIn actionWithDuration:.3]];
    if (![self hasItem:9]) [locked9 runAction:[CCFadeIn actionWithDuration:.3]];
    
    [equipped_skins runAction:[CCFadeIn actionWithDuration:.3]];
}
-(void)fadeInMenuSkins
{
    [menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
    [menuSkins_defaultMenu runAction:[CCFadeIn actionWithDuration:.3]];
    [black runAction:[CCFadeIn actionWithDuration:.3]];
    [blue runAction:[CCFadeIn actionWithDuration:.3]];
    [green runAction:[CCFadeIn actionWithDuration:.3]];
    
    if (![self hasItem:4]) [locked4 runAction:[CCFadeIn actionWithDuration:.3]];
    if (![self hasItem:5]) [locked5 runAction:[CCFadeIn actionWithDuration:.3]];
    if (![self hasItem:6]) [locked6 runAction:[CCFadeIn actionWithDuration:.3]];
    
    [equipped_menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
}



-(void)back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


-(void)skinDefault
{
    equipped_skins.opacity = 0;
    equipped_skins.position = skins_defaultMenu.position;
    [equipped_skins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:SKINS_DEFAULT forKey:@"equipped_skin"];
}
-(void)squares
{
    equipped_skins.opacity = 0;
    equipped_skins.position = squaresMenu.position;
    [equipped_skins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:SKINS_SQUARE forKey:@"equipped_skin"];
}
-(void)diamonds
{
    equipped_skins.opacity = 0;
    equipped_skins.position = diamondsMenu.position;
    [equipped_skins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:SKINS_DIAMOND forKey:@"equipped_skin"];
}
-(void)stars
{
    equipped_skins.opacity = 0;
    equipped_skins.position = starsMenu.position;
    [equipped_skins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:SKINS_STAR forKey:@"equipped_skin"];
}



-(void)menuSkinDefault
{
    equipped_menuSkins.opacity = 0;
    equipped_menuSkins.position = menuSkins_defaultMenu.position;
    [equipped_menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:MENU_SKINS_DEFAULT forKey:@"equipped_menu_skin"];
}
-(void)black
{
    equipped_menuSkins.opacity = 0;
    equipped_menuSkins.position = blackMenu.position;
    [equipped_menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:MENU_SKINS_BLACK forKey:@"equipped_menu_skin"];
}
-(void)blue
{
    equipped_menuSkins.opacity = 0;
    equipped_menuSkins.position = blueMenu.position;
    [equipped_menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:MENU_SKINS_BLUE forKey:@"equipped_menu_skin"];
}
-(void)green
{
    equipped_menuSkins.opacity = 0;
    equipped_menuSkins.position = greenMenu.position;
    [equipped_menuSkins runAction:[CCFadeIn actionWithDuration:.3]];
    [[NSUserDefaults standardUserDefaults] setInteger:MENU_SKINS_GREEN forKey:@"equipped_menu_skin"];
}


-(bool)hasItem:(int)n
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"shop_item%d", n]];
}

@end
