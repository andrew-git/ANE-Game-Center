//
//  GameCenterIosExtension
//  GameCenterIosExtension.m
//
//  Created by Richard Lord on 19/12/2011.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <GameKit/GameKit.h>
#import "GameCenterMessages.h"
#import "BoardsController.h"
#import "BoardsControllerPhone.h"
#import "BoardsControllerPad.h"
#import "FRETypeConversion.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define DISPATCH_STATUS_EVENT(extensionContext, code, status) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)status)

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

id<BoardsController> boardsController;
NSMutableDictionary* returnObjects;

void createBoardsController( FREContext context )
{
    if( !boardsController )
    {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            boardsController = [[BoardsControllerPad alloc] initWithContext:context];
        }
        else
        {
            boardsController = [[BoardsControllerPhone alloc] initWithContext:context];
        }
    }
}

NSString* storeReturnObject( id object )
{
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [returnObjects valueForKey:key] != nil );
    [returnObjects setValue:object forKey:key];
    return key;
}

id getReturnObject( NSString* key )
{
    id object = [returnObjects valueForKey:key];
    [returnObjects setValue:nil forKey:key];
    return object;
}

FREResult FRENewObjectFromGKScore( GKScore* score, FREObject* asScore )
{
    FREResult result;
    FREObject category;
    FREObject value;
    FREObject formattedValue;
    FREObject date;
    FREObject playerId;
    FREObject rank;
    result = FRENewObject( ASScore, 0, NULL, asScore, NULL);
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromUTF8( score.category.length, (uint8_t*) score.category.UTF8String, &category );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "category", category, NULL );
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromInt32( score.value, &value );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "value", value, NULL );
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromUTF8( score.formattedValue.length, (uint8_t*) score.formattedValue.UTF8String, &formattedValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "formattedValue", formattedValue, NULL );
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromDate( score.date, &date );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "date", date, NULL );
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromUTF8( score.playerID.length, (uint8_t*) score.playerID.UTF8String, &playerId );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "playerId", playerId, NULL );
    if( result != FRE_OK ) return result;
    
    result = FRENewObjectFromInt32( score.rank, &rank );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asScore, "rank", rank, NULL );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

DEFINE_ANE_FUNCTION( initNativeCode )
{
    return NULL;
}

DEFINE_ANE_FUNCTION( isSupported )
{
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // The device must be running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    uint32_t retValue = (localPlayerClassAvailable && osVersionSupported) ? 1 : 0;

    FREObject result;
    if ( FRENewObjectFromBool(retValue, &result ) == FRE_OK )
    {
        return result;
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( authenticateLocalPlayer )
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if( localPlayer )
    {
        if ( localPlayer.isAuthenticated )
        {
            DISPATCH_STATUS_EVENT( context, "", localPlayerAuthenticated );
            return NULL;
        }
        else
        {
            [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
                if( localPlayer.isAuthenticated )
                {
                    DISPATCH_STATUS_EVENT( context, "", localPlayerAuthenticated );
                }
                else
                {     
                    DISPATCH_STATUS_EVENT( context, "", localPlayerNotAuthenticated );
                }
            }];
        }
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( getLocalPlayer )
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if ( localPlayer && localPlayer.isAuthenticated )
    {
        FREObject result;
        FREObject playerId;
        FREObject alias;
        if ( FRENewObject( ASLocalPlayer, 0, NULL, &result, NULL ) == FRE_OK
            && FRENewObjectFromUTF8( localPlayer.playerID.length, (uint8_t*) localPlayer.playerID.UTF8String, &playerId ) == FRE_OK
            && FRESetObjectProperty( result, "id", playerId, NULL ) == FRE_OK
            && FRENewObjectFromUTF8( localPlayer.alias.length, (uint8_t*) localPlayer.alias.UTF8String, &alias ) == FRE_OK
            && FRESetObjectProperty( result, "alias", alias, NULL ) == FRE_OK )
        {
            return result;
        }
    }
    else
    {
        DISPATCH_STATUS_EVENT( context, "", notAuthenticated );
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( reportScore )
{
    uint32_t length = 0;
    const uint8_t* categoryValue = NULL;
    int32_t scoreValue = 0;
    
    if( FREGetObjectAsUTF8( argv[0], &length, &categoryValue ) != FRE_OK ) return NULL;
    NSString* category = [NSString stringWithUTF8String: (char*) categoryValue];
    
    if( FREGetObjectAsInt32( argv[1], &scoreValue ) != FRE_OK ) return NULL;
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated )
    {
        DISPATCH_STATUS_EVENT( context, "", notAuthenticated );
        return NULL;
    }
    
    GKScore* score = [[[GKScore alloc] initWithCategory:category] autorelease];
    if( score )
    {
        score.value = scoreValue;
        [score reportScoreWithCompletionHandler:^(NSError* error)
        {
            if( error == nil )
            {
                DISPATCH_STATUS_EVENT( context, "", scoreReported );
            }
            else
            {
                DISPATCH_STATUS_EVENT( context, "", scoreNotReported );
            }
        }];
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( showStandardLeaderboard )
{
    createBoardsController( context );
    [boardsController displayLeaderboard];
    return NULL;
}

DEFINE_ANE_FUNCTION( showStandardLeaderboardWithCategory )
{
    uint32_t length = 0;
    const uint8_t* categoryValue = NULL;
    if( FREGetObjectAsUTF8( argv[0], &length, &categoryValue ) != FRE_OK ) return NULL;
    NSString* category = [NSString stringWithUTF8String: (char*) categoryValue];
    
    createBoardsController( context );
    [boardsController displayLeaderboardWithCategory:category];
    return NULL;
}

DEFINE_ANE_FUNCTION( showStandardLeaderboardWithTimescope )
{
    int timeScope;
    if( FREGetObjectAsInt32( argv[1], &timeScope ) != FRE_OK ) return NULL;
    
    createBoardsController( context );
    [boardsController displayLeaderboardWithTimescope:timeScope];
    return NULL;
}

DEFINE_ANE_FUNCTION( showStandardLeaderboardWithCategoryAndTimescope )
{
    int timeScope;
    uint32_t length = 0;
    const uint8_t* categoryValue = NULL;
    if( FREGetObjectAsUTF8( argv[0], &length, &categoryValue ) != FRE_OK ) return NULL;
    NSString* category = [NSString stringWithUTF8String: (char*) categoryValue];
    if( FREGetObjectAsInt32( argv[1], &timeScope ) != FRE_OK ) return NULL;
    
    createBoardsController( context );
    [boardsController displayLeaderboardWithCategory:category andTimescope:timeScope];
    return NULL;
}

DEFINE_ANE_FUNCTION( reportAchievement )
{
    uint32_t length = 0;
    const uint8_t* identifierValue = NULL;
    double achievementValue = 0;
    
    if( FREGetObjectAsUTF8( argv[0], &length, &identifierValue ) != FRE_OK ) return NULL;
    NSString* identifier = [NSString stringWithUTF8String: (char*) identifierValue];
    
    if( FREGetObjectAsDouble( argv[1], &achievementValue ) != FRE_OK ) return NULL;
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated )
    {
        DISPATCH_STATUS_EVENT( context, "", notAuthenticated );
        return NULL;
    }
    
    GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    if( achievement )
    {
        achievement.percentComplete = achievementValue * 100;
        [achievement reportAchievementWithCompletionHandler:^(NSError* error)
         {
             if( error == nil )
             {
                 DISPATCH_STATUS_EVENT( context, "", achievementReported );
             }
             else
             {
                 DISPATCH_STATUS_EVENT( context, "", achievementNotReported );
             }
         }];
    }
    return NULL;
}


DEFINE_ANE_FUNCTION( showStandardAchievements )
{
    createBoardsController( context );
    [boardsController displayAchievements];
    return NULL;
}

DEFINE_ANE_FUNCTION( getLocalPlayerFriends )
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated )
    {
        DISPATCH_STATUS_EVENT( context, "", notAuthenticated );
        return NULL;
    }
    [localPlayer loadFriendsWithCompletionHandler:^(NSArray *friendIds, NSError *error)
    {
        if ( error == nil && friendIds != nil )
        {
            if( friendIds.count == 0 )
            {
                [friendIds retain];
                NSString* code = storeReturnObject( friendIds );
                DISPATCH_STATUS_EVENT( context, code.UTF8String, loadFriendsComplete );
            }
            else
            {
                [GKPlayer loadPlayersForIdentifiers:friendIds withCompletionHandler:^(NSArray *friendDetails, NSError *error)
                {
                    if ( error == nil && friendDetails != nil )
                    {
                        [friendDetails retain];
                        NSString* code = storeReturnObject( friendDetails );
                        DISPATCH_STATUS_EVENT( context, code.UTF8String, loadFriendsComplete );
                    }
                    else
                    {
                        DISPATCH_STATUS_EVENT( context, "", loadFriendsFailed );
                    }
                }];
            }
        }
        else
        {
            DISPATCH_STATUS_EVENT( context, "", loadFriendsFailed );
        }
    }];
    return NULL;
}

DEFINE_ANE_FUNCTION( getLocalPlayerScore )
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if( !localPlayer.isAuthenticated )
    {
        DISPATCH_STATUS_EVENT( context, "", notAuthenticated );
        return NULL;
    }
    
    GKLeaderboard* leaderboard = [[GKLeaderboard alloc] init];

    uint32_t length = 0;
    const uint8_t* categoryString = NULL;
    if( FREGetObjectAsUTF8( argv[0], &length, &categoryString ) != FRE_OK ) return NULL;
    leaderboard.category = [NSString stringWithUTF8String: (char*) categoryString];

    int propertyInt;
    if( FREGetObjectAsInt32( argv[1], &propertyInt ) != FRE_OK ) return NULL;
    leaderboard.playerScope = propertyInt;
    
    if( FREGetObjectAsInt32( argv[2], &propertyInt ) != FRE_OK ) return NULL;
    leaderboard.timeScope = propertyInt;
    
    leaderboard.range = NSMakeRange( 1, 1 );
    
    [leaderboard loadScoresWithCompletionHandler:^( NSArray* scores, NSError* error )
    {
        if( error == nil && scores != nil )
        {
            NSString* code = storeReturnObject( leaderboard );
            DISPATCH_STATUS_EVENT( context, code.UTF8String, loadLocalPlayerScoreComplete );
        }
        else
        {
            [leaderboard release];
            DISPATCH_STATUS_EVENT( context, "", loadLocalPlayerScoreFailed );
        }
    }];
    return NULL;
}

DEFINE_ANE_FUNCTION( getStoredLocalPlayerScore )
{
    uint32_t length = 0;
    const uint8_t* keyValue = NULL;
    if( FREGetObjectAsUTF8( argv[0], &length, &keyValue ) != FRE_OK ) return NULL;
    NSString* key = [NSString stringWithUTF8String: (char*) keyValue];
    GKLeaderboard* leaderboard = getReturnObject( key );
    
    if( leaderboard == nil )
    {
        return NULL;
    }
    FREObject asLeaderboard;
    FREObject asTimeScope;
    FREObject asPlayerScope;
    FREObject asCategory;
    FREObject asTitle;
    FREObject asScore;
    FREObject asRangeMax;
    
    if ( FRENewObject( ASLeaderboard, 0, NULL, &asLeaderboard, NULL) == FRE_OK
        && FRENewObjectFromInt32( leaderboard.timeScope, &asTimeScope ) == FRE_OK
        && FRESetObjectProperty( asLeaderboard, "timeScope", asTimeScope, NULL ) == FRE_OK
        && FRENewObjectFromInt32( leaderboard.playerScope, &asPlayerScope ) == FRE_OK
        && FRESetObjectProperty( asLeaderboard, "playerScope", asPlayerScope, NULL ) == FRE_OK
        && FRENewObjectFromUTF8( leaderboard.category.length, (uint8_t*) leaderboard.category.UTF8String, &asCategory ) == FRE_OK
        && FRESetObjectProperty( asLeaderboard, "category", asCategory, NULL ) == FRE_OK
        && FRENewObjectFromUTF8( leaderboard.title.length, (uint8_t*) leaderboard.title.UTF8String, &asTitle ) == FRE_OK
        && FRESetObjectProperty( asLeaderboard, "title", asTitle, NULL ) == FRE_OK
        && FRENewObjectFromInt32( leaderboard.maxRange, &asRangeMax ) == FRE_OK
        && FRESetObjectProperty( asLeaderboard, "rangeMax", asRangeMax, NULL ) == FRE_OK )
    {
        if( leaderboard.localPlayerScore && FRENewObjectFromGKScore( leaderboard.localPlayerScore, &asScore ) == FRE_OK )
        {
            FRESetObjectProperty( asLeaderboard, "localPlayerScore", asScore, NULL );
        }
        [leaderboard release];
        return asLeaderboard;
    }
    [leaderboard release];
    return NULL;
}

DEFINE_ANE_FUNCTION( getStoredPlayers )
{
    uint32_t length = 0;
    const uint8_t* keyValue = NULL;
    if( FREGetObjectAsUTF8( argv[0], &length, &keyValue ) != FRE_OK ) return NULL;
    NSString* key = [NSString stringWithUTF8String: (char*) keyValue];
    NSArray* friendDetails = getReturnObject( key );
    if( friendDetails == nil )
    {
        return NULL;
    }
    NSLog( @"Friends %@", friendDetails );
    FREObject friends;
    if ( FRENewObject( "Array", 0, NULL, &friends, NULL ) == FRE_OK && FRESetArrayLength( friends, friendDetails.count ) == FRE_OK )
    {
        int nextIndex = 0;
        for( GKPlayer* friend in friendDetails )
        {
            FREObject asPlayer;
            FREObject playerId;
            FREObject alias;
            FREObject isFriend;
            if( FRENewObject( ASPlayer, 0, NULL, &asPlayer, NULL ) == FRE_OK 
               && FRENewObjectFromUTF8( friend.playerID.length, (uint8_t*) friend.playerID.UTF8String, &playerId ) == FRE_OK && FRESetObjectProperty( asPlayer, "id", playerId, NULL ) == FRE_OK
               && FRENewObjectFromUTF8( friend.alias.length, (uint8_t*) friend.alias.UTF8String, &alias ) == FRE_OK && FRESetObjectProperty( asPlayer, "alias", alias, NULL ) == FRE_OK
               && FRENewObjectFromBool( friend.isFriend, &isFriend ) == FRE_OK && FRESetObjectProperty( asPlayer, "isFriend", isFriend, NULL ) == FRE_OK
               )
            {
                FRESetArrayElementAt( friends, nextIndex, asPlayer );
                ++nextIndex;
            }
        }
        [friendDetails release];
        return friends;
    }
    [friendDetails release];
    return NULL;
}

void GameCenterContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet )
{
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION( initNativeCode, NULL ),
        MAP_FUNCTION( isSupported, NULL ),
        MAP_FUNCTION( authenticateLocalPlayer, NULL ),
        MAP_FUNCTION( getLocalPlayer, NULL ),
        MAP_FUNCTION( reportScore, NULL ),
        MAP_FUNCTION( reportAchievement, NULL ),
        MAP_FUNCTION( showStandardLeaderboard, NULL ),
        MAP_FUNCTION( showStandardLeaderboardWithCategory, NULL ),
        MAP_FUNCTION( showStandardLeaderboardWithTimescope, NULL ),
        MAP_FUNCTION( showStandardLeaderboardWithCategoryAndTimescope, NULL ),
        MAP_FUNCTION( showStandardAchievements, NULL ),
        MAP_FUNCTION( getLocalPlayerFriends, NULL ),
        MAP_FUNCTION( getLocalPlayerScore, NULL ),
        MAP_FUNCTION( getStoredLocalPlayerScore, NULL ),
        MAP_FUNCTION( getStoredPlayers, NULL )
    };
    
	*numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
}

void GameCenterContextFinalizer( FREContext ctx )
{
	return;
}

void GameCenterExtensionInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{ 
    extDataToSet = NULL;  // This example does not use any extension data. 
    *ctxInitializerToSet = &GameCenterContextInitializer;
    *ctxFinalizerToSet = &GameCenterContextFinalizer;
    returnObjects = [[NSMutableDictionary alloc] init];
}

void GameCenterExtensionFinalizer()
{
    return;
}
