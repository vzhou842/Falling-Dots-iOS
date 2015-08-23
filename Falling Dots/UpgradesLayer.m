//
//  UpgradesLayer.m
//  Falling Dots
//
//  Created by Victor Zhou on 5/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "UpgradesLayer.h"
#import "MainMenuLayer.h"
#import "GameOverLayer.h"
#define OFFSETY ([[CCDirector sharedDirector] winSize].height-480)/2.0
#define CENTERY [[CCDirector sharedDirector] winSize].height/2.0


@implementation UpgradesLayer

+(CCScene *) sceneWithScore:(int)s combo:(int)c forMode:(int)mode fromMainMenu:(bool)flag
{
	CCScene *scene = [CCScene node];
	UpgradesLayer *layer = [[UpgradesLayer alloc] initWithScore:s combo:c forMode:mode fromMainMenu:flag];
	[scene addChild: layer];
	return scene;
}

+(CCScene *)sceneFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDisconnect:(bool)dc
{
    CCScene *scene = [CCScene node];
	UpgradesLayer *layer = [[UpgradesLayer alloc] initFromMultiplayerWithPlayerScore:pScore enemyScore:eScore withDisconnect:dc];
	[scene addChild: layer];
	return scene;
}

-(id)initWithScore:(int)s combo:(int)c forMode:(int)mode fromMainMenu:(bool)flag
{
    if (self = [super init])
    {
        score = s;
        gameMode = mode;
        combo = c;
        
        fromMainMenu = flag;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        //top
        top = [CCSprite spriteWithFile:@"upgrades_top.png"];
        top.position = ccp(160, 2*CENTERY-21+100);
        [self addChild:top];
        [top runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 2*CENTERY-21)]];
        
        //back
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-300,2*CENTERY-21);
        [self addChild:backMenu];
        [backMenu runAction:[CCMoveTo actionWithDuration:1.8 position:CGPointMake(15, 2*CENTERY-21)]];
        
        //bars background
        bars = [CCSprite spriteWithFile:@"upgrades_bars.png"];
        bars.position = ccp(160, CENTERY-20);
        [self addChild:bars];
        bars.opacity = 0;
        [self scheduleOnce:@selector(barsFadeIn) delay:.55];
        
        //plus menu
        [self updatePlusSigns];
        plusMenu.opacity = 0;
         
         //bars
         bar1 = [CCSprite spriteWithFile:@"gameOver_barBlack.png"];
         bar1.anchorPoint = CGPointMake(0, .5);
         //bar1.scaleX = [self barVal:1]/100.0;
         bar1.scaleX = 0;
         bar1.scaleY = .5;
         bar1.position = ccp(75, CENTERY-20+8+2*79);
         [self addChild:bar1];
         
         bar2 = [CCSprite spriteWithFile:@"gameOver_barGreen.png"];
         bar2.anchorPoint = CGPointMake(0, .5);
         //bar2.scaleX = [self barVal:2]/100.0;
         bar2.scaleX = 0;
         bar2.scaleY = .5;
         bar2.position = ccp(75, CENTERY-20+8+79);
         [self addChild:bar2];
         
         bar3 = [CCSprite spriteWithFile:@"gameOver_barRed.png"];
         bar3.anchorPoint = CGPointMake(0, .5);
         //bar3.scaleX = [self barVal:3]/100.0;
         bar3.scaleX = 0;
         bar3.scaleY = .5;
         bar3.position = ccp(75, CENTERY-20+8);
         [self addChild:bar3];
         
         bar4 = [CCSprite spriteWithFile:@"gameOver_barBlue.png"];
         bar4.anchorPoint = CGPointMake(0, .5);
         //bar4.scaleX = [self barVal:4]/100.0;
         bar4.scaleX = 0;
         bar4.scaleY = .5;
         bar4.position = ccp(75, CENTERY-20+8-79);
         [self addChild:bar4];
         
         bar5 = [CCSprite spriteWithFile:@"gameOver_barPurple.png"];
         bar5.anchorPoint = CGPointMake(0, .5);
         //bar5.scaleX = [self barVal:5]/100.0;
         bar5.scaleX = 0;
         bar5.scaleY = .5;
         bar5.position = ccp(75, CENTERY-20+8-2*79);
         [self addChild:bar5];
        
        [self scheduleOnce:@selector(scaleBars) delay:1.05];
        

        [self triggerVideo];
    }
    return self;
}

-(id)initFromMultiplayerWithPlayerScore:(int)pScore enemyScore:(int)eScore withDisconnect:(bool)dc
{
    if (self = [super init])
    {
        playerScore = pScore;
        enemyScore = eScore;
        fromMultiplayer = YES;
        disconnect = dc;
        
        background = [CCSprite spriteWithFile:@"background_game.png"];
        background.position = ccp(160, CENTERY);
        [self addChild:background];
        
        //top
        top = [CCSprite spriteWithFile:@"upgrades_top.png"];
        top.position = ccp(160, 2*CENTERY-21+100);
        [self addChild:top];
        [top runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, 2*CENTERY-21)]];
        
        //back
        back = [CCMenuItemImage itemWithNormalImage:@"gameOver_back.png" selectedImage:@"gameOver_backSelected.png" target:self selector:@selector(back)];
        backMenu = [CCMenu menuWithItems:back, nil];
        backMenu.position = ccp(15-300,2*CENTERY-21);
        [self addChild:backMenu];
        [backMenu runAction:[CCMoveTo actionWithDuration:1.8 position:CGPointMake(15, 2*CENTERY-21)]];
        
        //bars background
        bars = [CCSprite spriteWithFile:@"upgrades_bars.png"];
        bars.position = ccp(160, CENTERY-20);
        [self addChild:bars];
        bars.opacity = 0;
        [self scheduleOnce:@selector(barsFadeIn) delay:.55];
        
        //plus menu
        [self updatePlusSigns];
        plusMenu.opacity = 0;
        
        //bars
        bar1 = [CCSprite spriteWithFile:@"gameOver_barBlack.png"];
        bar1.anchorPoint = CGPointMake(0, .5);
        //bar1.scaleX = [self barVal:1]/100.0;
        bar1.scaleX = 0;
        bar1.scaleY = .5;
        bar1.position = ccp(75, CENTERY-20+8+2*79);
        [self addChild:bar1];
        
        bar2 = [CCSprite spriteWithFile:@"gameOver_barGreen.png"];
        bar2.anchorPoint = CGPointMake(0, .5);
        //bar2.scaleX = [self barVal:2]/100.0;
        bar2.scaleX = 0;
        bar2.scaleY = .5;
        bar2.position = ccp(75, CENTERY-20+8+79);
        [self addChild:bar2];
        
        bar3 = [CCSprite spriteWithFile:@"gameOver_barRed.png"];
        bar3.anchorPoint = CGPointMake(0, .5);
        //bar3.scaleX = [self barVal:3]/100.0;
        bar3.scaleX = 0;
        bar3.scaleY = .5;
        bar3.position = ccp(75, CENTERY-20+8);
        [self addChild:bar3];
        
        bar4 = [CCSprite spriteWithFile:@"gameOver_barBlue.png"];
        bar4.anchorPoint = CGPointMake(0, .5);
        //bar4.scaleX = [self barVal:4]/100.0;
        bar4.scaleX = 0;
        bar4.scaleY = .5;
        bar4.position = ccp(75, CENTERY-20+8-79);
        [self addChild:bar4];
        
        bar5 = [CCSprite spriteWithFile:@"gameOver_barPurple.png"];
        bar5.anchorPoint = CGPointMake(0, .5);
        //bar5.scaleX = [self barVal:5]/100.0;
        bar5.scaleX = 0;
        bar5.scaleY = .5;
        bar5.position = ccp(75, CENTERY-20+8-2*79);
        [self addChild:bar5];
        
        [self scheduleOnce:@selector(scaleBars) delay:1.05];
        
        
        [self triggerVideo];
    }
    return self;
}

-(void)barsFadeIn
{
    [bars runAction:[CCFadeIn actionWithDuration:.5]];
    [plusMenu runAction:[CCFadeIn actionWithDuration:.5]];
    
    //dot points left to spend
    dotPointsSpendable = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]] fontName:@"Eurostile" fontSize:20];
    dotPointsSpendable.position = ccp(160, 2*CENTERY-60);
    dotPointsSpendable.color = ccBLACK;
    [self addChild:dotPointsSpendable];
    dotPointsSpendable.opacity = 0;
    [dotPointsSpendable runAction:[CCFadeIn actionWithDuration:.5]];
    
    //more dots
    moreDots = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(moreDots)];
    moreDotsMenu = [CCMenu menuWithItems:moreDots, nil];
    moreDotsMenu.position = ccp(160+dotPointsSpendable.boundingBox.size.width/2.0+16, dotPointsSpendable.position.y);
    [self addChild:moreDotsMenu];
    moreDotsMenu.opacity = 0;
    [moreDotsMenu runAction:[CCFadeIn actionWithDuration:.5]];
    
}
-(void)scaleBars
{
    [bar1 runAction:[CCScaleTo actionWithDuration:.3 scaleX:[self barVal:1]/200.0 scaleY:.5]];
    [bar2 runAction:[CCScaleTo actionWithDuration:.3 scaleX:[self barVal:2]/200.0 scaleY:.5]];
    [bar3 runAction:[CCScaleTo actionWithDuration:.3 scaleX:[self barVal:3]/200.0 scaleY:.5]];
    [bar4 runAction:[CCScaleTo actionWithDuration:.3 scaleX:[self barVal:4]/200.0 scaleY:.5]];
    [bar5 runAction:[CCScaleTo actionWithDuration:.3 scaleX:[self barVal:5]/200.0 scaleY:.5]];
}

-(void)plus1
{
    if ([self dotPoints] <= 0) return;
    [self setDotPoints:[self dotPoints]-1];
    [self setBarValTo:[self barVal:1]+1 for:1];
    [self updateBars];
    [self updatePlusSigns];
}
-(void)plus2
{
    if ([self dotPoints] <= 0) return;
    [self setDotPoints:[self dotPoints]-1];
    [self setBarValTo:[self barVal:2]+1 for:2];
    [self updateBars];
    [self updatePlusSigns];
}
-(void)plus3
{
    if ([self dotPoints] <= 0) return;
    [self setDotPoints:[self dotPoints]-1];
    [self setBarValTo:[self barVal:3]+1 for:3];
    [self updateBars];
    [self updatePlusSigns];
}
-(void)plus4
{
    if ([self dotPoints] <= 0) return;
    [self setDotPoints:[self dotPoints]-1];
    [self setBarValTo:[self barVal:4]+1 for:4];
    [self updateBars];
    [self updatePlusSigns];
}
-(void)plus5
{
    if ([self dotPoints] <= 0) return;
    [self setDotPoints:[self dotPoints]-1];
    [self setBarValTo:[self barVal:5]+1 for:5];
    [self updateBars];
    [self updatePlusSigns];
}


-(void)back
{
    if (fromMultiplayer)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[GameOverLayer sceneFromMultiplayerWithPlayerScore:playerScore enemyScore:enemyScore withDotRatingGain:0 withAnimations:NO withDisconnect:disconnect]]];
        return;
    }
    if (!fromMainMenu) [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[GameOverLayer sceneWithScore:score combo:combo forMode:gameMode withAnimations:NO]]];
    else [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.3 scene:[MainMenuLayer scene]]];
}


-(void)updateDotPoints
{
    numUpdateDPLoops = 0;
    DPinitial = [self dotPoints];
    [self schedule:@selector(updateDotPointsLoop) interval:1/30.0];
    [[NSUserDefaults standardUserDefaults] setInteger:[self dotPoints]+DPgained forKey:@"dotPoints"];
    [self updatePlusSigns];
    
}
-(void)updateDotPointsLoop
{
    dotPointsSpendable.string = [NSString stringWithFormat:@"Your Dot Points: %d", DPinitial+(int)(DPgained*numUpdateDPLoops/20.0)];
    moreDotsMenu.position = ccp(160+dotPointsSpendable.boundingBox.size.width/2.0+16, dotPointsSpendable.position.y);
    numUpdateDPLoops++;
    if (numUpdateDPLoops == 20)
    {
        [self setDotPoints:[self dotPoints]]; //already added them directly through NSUserDefaults in updateDotPoints
        [self unschedule:@selector(updateDotPointsLoop)];
    }
}


//---------------------------------------I A P STUFF---------------------------------------
-(void)moreDots
{
    isInIAP = YES;
    [backMenu setEnabled:NO];
    [moreDotsMenu setEnabled:NO];
    
    faded75 = [CCSprite spriteWithFile:@"faded75.png"];
    faded75.position = ccp(160, CENTERY);
    [self addChild:faded75];
    
    background_IAP = [CCSprite spriteWithFile:@"gameOver_IAP.png"];
    background_IAP.position = ccp(160, 3*CENTERY);
    [self addChild:background_IAP];
    [background_IAP runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY)]];
    
    buy200 = [CCMenuItemImage itemWithNormalImage:@"IAP_buy200.png" selectedImage:@"IAP_buy200Selected.png" target:self selector:@selector(buy200)];
    buy500 = [CCMenuItemImage itemWithNormalImage:@"IAP_buy500.png" selectedImage:@"IAP_buy500Selected.png" target:self selector:@selector(buy500)];
    IAPmenu = [CCMenu menuWithItems:buy200, buy500, nil];
    IAPmenu.position = ccp(160, 3*CENTERY-15);
    [IAPmenu alignItemsVerticallyWithPadding:75];
    [self addChild:IAPmenu];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY-15)]];
    
    close = [CCMenuItemImage itemWithNormalImage:@"IAP_close.png" selectedImage:@"IAP_closeSelected.png" target:self selector:@selector(closeIAP)];
    IAPcloseMenu = [CCMenu menuWithItems:close, nil];
    IAPcloseMenu.position = ccp(160, 3*CENTERY-160);
    [self addChild:IAPcloseMenu];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.5 position:CGPointMake(160, CENTERY-160)]];
    
    IAP_loading = [CCSprite spriteWithFile:@"IAP_loading.png"];
    IAP_loading.position = ccp(480, CENTERY);
    [self addChild:IAP_loading];
}

-(void)buy200
{
    IAP_loading.position = ccp(480, CENTERY);
    [IAP_loading runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    
    [background_IAP runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY-160)]];
    
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.victorzhougames.webs.200DP"]];
    request.delegate = self;
    [request start];
}

-(void)buy500
{
    IAP_loading.position = ccp(480, CENTERY);
    [IAP_loading runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(160, CENTERY)]];
    
    [background_IAP runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPmenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY)]];
    [IAPcloseMenu runAction:[CCMoveTo actionWithDuration:.3 position:CGPointMake(-160, CENTERY-160)]];
    
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.victorzhougames.webs.500DP"]];
    request.delegate = self;
    [request start];
}

-(void)closeIAP
{
    isInIAP = NO;
    [backMenu setEnabled:YES];
    [moreDotsMenu setEnabled:YES];
    
    [self removeChild:background_IAP cleanup:YES];
    [self removeChild:faded75 cleanup:YES];
    [self removeChild:IAPcloseMenu cleanup:YES];
    [self removeChild:IAPmenu cleanup:YES];
    [self removeChild:IAP_loading cleanup:YES];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
    
    //Since only one product, we do not need to choose from the array. Proceed directly to payment.
    
    SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:newPayment];
    
    [request autorelease];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    [self closeIAP];
    
    // Display an error here.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed"
                                                    message:[NSString stringWithFormat:@"Please try again - make sure you are connected to the internet."]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}


//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");
    
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    if ([transaction.payment.productIdentifier isEqualToString:@"com.victorzhougames.webs.200DP"])
    {
        //+200
        hasUpdatedDotPoints = NO;
        DPgained = 200;
        [self scheduleOnce:@selector(updateDotPoints) delay:0];
        [self closeIAP];
    }
    else if ([transaction.payment.productIdentifier isEqualToString:@"com.victorzhougames.webs.500DP"])
    {
        //+500
        hasUpdatedDotPoints = NO;
        DPgained = 500;
        [self scheduleOnce:@selector(updateDotPoints) delay:0];
        [self closeIAP];
    }
    else NSLog(@"UNKNOWN PRODUCT IDENTIFIER: %@", transaction.payment.productIdentifier);
    
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restored");
    
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    [self closeIAP];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    [self closeIAP];
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:[NSString stringWithFormat:@"Your purchase failed: %@. Please try again.", transaction.error.localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self closeIAP];
    if (error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:[NSString stringWithFormat:@"Your purchase failed: %@. Please try again.", error.localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


//----------NSUSERDEFAULT STUFF-------------


-(void)updateBars
{
    bar1.scaleX = [self barVal:1]/200.0;
    bar2.scaleX = [self barVal:2]/200.0;
    bar3.scaleX = [self barVal:3]/200.0;
    bar4.scaleX = [self barVal:4]/200.0;
    bar5.scaleX = [self barVal:5]/200.0;
}
-(void)updatePlusSigns
{
    if ([[self children] containsObject:plusMenu]) [self removeChild:plusMenu cleanup:YES];
    plus1 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(plus1)];
    plus2 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(plus2)];
    plus3 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(plus3)];
    plus4 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(plus4)];
    plus5 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plus.png" selectedImage:@"gameOver_plusSelected.png" target:self selector:@selector(plus5)];
    
    if ([self barVal:1] == 200 || [self dotPoints] == 0)
    {
        plus1 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plusGrayed.png" selectedImage:@"gameOver_plusGrayed.png"];
    }
    if ([self barVal:2] == 200 || [self dotPoints] == 0)
    {
        plus2 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plusGrayed.png" selectedImage:@"gameOver_plusGrayed.png"];
    }
    if ([self barVal:3] == 200 || [self dotPoints] == 0)
    {
        plus3 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plusGrayed.png" selectedImage:@"gameOver_plusGrayed.png"];
    }
    if ([self barVal:4] == 200 || [self dotPoints] == 0)
    {
        plus4 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plusGrayed.png" selectedImage:@"gameOver_plusGrayed.png"];
    }
    if ([self barVal:5] == 200 || [self dotPoints] == 0)
    {
        plus5 = [CCMenuItemImage itemWithNormalImage:@"gameOver_plusGrayed.png" selectedImage:@"gameOver_plusGrayed.png"];
    }
    
    
    plusMenu = [CCMenu menuWithItems:plus1, plus2, plus3, plus4, plus5, nil];
    [plusMenu alignItemsVerticallyWithPadding:47];
    plusMenu.position = ccp(302, CENTERY-20+8);
    [self addChild:plusMenu];
}

-(int)barVal:(int)n
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"barVal%d", n]];
}
-(void)setBarValTo:(int)val for:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:val forKey:[NSString stringWithFormat:@"barVal%d", n]];
}

-(int)dotPoints
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dotPoints"];
}
-(void)setDotPoints:(int)n
{
    [[NSUserDefaults standardUserDefaults] setInteger:n forKey:@"dotPoints"];
    dotPointsSpendable.string = [NSString stringWithFormat:@"Your Dot Points: %d", [self dotPoints]];
}
-(void)triggerVideo {
    [AdColony playVideoAdForZone:@"vz6027548cc102427f8d"
                    withDelegate:nil
                withV4VCPrePopup:YES
                andV4VCPostPopup:YES];
}
@end
