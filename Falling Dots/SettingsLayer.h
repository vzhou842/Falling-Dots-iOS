//
//  SettingsLayer.h
//  Falling Dots
//
//  Created by Victor Zhou on 8/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define SKINS_DEFAULT 80
#define SKINS_SQUARE 81
#define SKINS_DIAMOND 82
#define SKINS_STAR 83

#define MENU_SKINS_DEFAULT 90
#define MENU_SKINS_BLACK 91
#define MENU_SKINS_BLUE 92
#define MENU_SKINS_GREEN 93

@interface SettingsLayer : CCLayer {
    
    CCSprite *background;
    CCSprite *top;
    
    CCMenu *backMenu;
    CCMenuItemImage *back;

    CCLabelTTF *skins, *menuSkins;
    
    CCMenuItemImage *squares, *diamonds, *stars, *skins_default;
    CCMenuItemImage *black, *blue, *green, *menuSkins_default;
    CCMenu *squaresMenu, *diamondsMenu, *starsMenu, *skins_defaultMenu;
    CCMenu *blackMenu, *blueMenu, *greenMenu, *menuSkins_defaultMenu;
    
    CCLabelTTF *locked7, *locked8, *locked9;
    CCLabelTTF *locked4, *locked5, *locked6;
    
    CCSprite *equipped_skins;
    CCSprite *equipped_menuSkins;
}

+(CCScene *)scene;

-(void)fadeInSkins;
-(void)fadeInMenuSkins;

-(void)back;

-(void)skinDefault;
-(void)squares;
-(void)diamonds;
-(void)stars;

-(void)menuSkinDefault;
-(void)black;
-(void)blue;
-(void)green;

-(bool)hasItem:(int)n;
@end




