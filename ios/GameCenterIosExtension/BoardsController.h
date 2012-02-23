//
//  BoardsController.h
//  GameCenterIosExtension
//
//  Created by Richard Lord on 01/02/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BoardsController <NSObject>
@required
-(id) initWithContext:(FREContext)context;
-(void) displayLeaderboard;
-(void) displayLeaderboardWithCategory:(NSString*)category;
-(void) displayLeaderboardWithCategory:(NSString*)category andTimescope:(int)timeScope;
-(void) displayLeaderboardWithTimescope:(int)timeScope;
-(void) displayAchievements;
@end
