//
//  AppDelegate.h
//  Falling Dots
//
//  Created by Victor Zhou on 5/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GameKit/GameKit.h"
#import "AdColony/AdColony.h"

//MODES
#define CLASSIC_MODE 400
#define ARCADE_MODE 401
#define MULTIPLAYER_MODE 404

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate, AdColonyDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref

}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

- (void)reportScore:(int)s forMode:(int)m;
-(int)bestScoreForMode:(int)m;
-(int)dotRating;

-(void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID;
@end

