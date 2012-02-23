//
//  BoardsControllerPad.h
//  GameCenterIosExtension
//
//  Created by Richard Lord on 01/02/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "FlashRuntimeExtensions.h"
#import "BoardsController.h"

@interface BoardsControllerPad : NSObject <BoardsController,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate>
{
    
}
-(id) initWithContext:(FREContext)context;
-(void) displayLeaderboard;
-(void) displayLeaderboardWithCategory:(NSString*)category;
-(void) displayLeaderboardWithCategory:(NSString*)category andTimescope:(int)timeScope;
-(void) displayLeaderboardWithTimescope:(int)timeScope;
-(void) displayAchievements;
@end
