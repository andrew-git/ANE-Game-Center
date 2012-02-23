//
//  BoardsViewController.h
//  GameCenterIosExtension
//
//  Created by Richard Lord on 20/12/2011.
//  Copyright (c) 2011 Stick Sports Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "FlashRuntimeExtensions.h"
#import "BoardsController.h"

@interface BoardsControllerPhone : UIViewController <BoardsController,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate>
{
    
}
-(id) initWithContext:(FREContext)context;
-(void) displayLeaderboard;
-(void) displayLeaderboardWithCategory:(NSString*)category;
-(void) displayLeaderboardWithCategory:(NSString*)category andTimescope:(int)timeScope;
-(void) displayLeaderboardWithTimescope:(int)timeScope;
-(void) displayAchievements;
@end
