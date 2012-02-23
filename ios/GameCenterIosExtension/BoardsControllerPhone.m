//
//  BoardsViewController.m
//  GameCenterIosExtension
//
//  Created by Richard Lord on 20/12/2011.
//  Copyright (c) 2011 Stick Sports Ltd. All rights reserved.
//

#import "BoardsControllerPhone.h"
#import "GameCenterMessages.h"

@interface BoardsControllerPhone () {
}

@property (retain) UIWindow* win;
@property FREContext context;

@end

@implementation BoardsControllerPhone

@synthesize win,context;

- (id)initWithContext:(FREContext)extensionContext
{
    self = [super init];
    if( self )
    {
        win = [UIApplication sharedApplication].keyWindow;
        context = extensionContext;
    }
    return self;
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    [self.view.superview removeFromSuperview];
    FREDispatchStatusEventAsync(context, "", gameCenterViewRemoved);
}

- (void)achievementViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    [self.view.superview removeFromSuperview];
    FREDispatchStatusEventAsync(context, "", gameCenterViewRemoved);
}

-(void) displayLeaderboard
{
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
    if( leaderboardController != nil )
    {
        leaderboardController.leaderboardDelegate = self;
        [win addSubview:self.view];
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

-(void) displayLeaderboardWithCategory:(NSString*)category
{
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
    if( leaderboardController != nil )
    {
        leaderboardController.category = category;
        leaderboardController.leaderboardDelegate = self;
        [win addSubview:self.view];
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

-(void) displayLeaderboardWithCategory:(NSString*)category andTimescope:(int)timeScope
{
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
    if( leaderboardController != nil )
    {
        leaderboardController.category = category;
        leaderboardController.timeScope = timeScope;
        leaderboardController.leaderboardDelegate = self;
        [win addSubview:self.view];
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

-(void) displayLeaderboardWithTimescope:(int)timeScope
{
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
    if( leaderboardController != nil )
    {
        leaderboardController.timeScope = timeScope;
        leaderboardController.leaderboardDelegate = self;
        [win addSubview:self.view];
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

-(void) displayAchievements
{
    GKAchievementViewController *achievementController = [[[GKAchievementViewController alloc] init] autorelease];
    if( achievementController != nil )
    {
        achievementController.achievementDelegate = self;
        [win addSubview:self.view];
        [self presentModalViewController: achievementController animated: YES];
    }
}

#pragma mark - Lifecycle

- (void)dealloc
{
    [super dealloc];
}

@end
