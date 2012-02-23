//
//  FRETypeConversion.c
//  GameCenterIosExtension
//
//  Created by Richard Lord on 25/01/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "FRETypeConversion.h"
/*
FREResult FREGetObjectAsNSString( FREObject object, NSString* value )
{
    FREResult result;
    uint32_t length = 0;
    const uint8_t* utf8Value = NULL;
    result = FREGetObjectAsUTF8( object, &length, &utf8Value );
    if( result != FRE_OK ) return result;
    value = [NSString stringWithUTF8String: (char*) utf8Value];
    return FRE_OK;
}
*/
FREResult FRENewObjectFromDate( NSDate* date, FREObject* asDate )
{
    NSTimeInterval timestamp = date.timeIntervalSince1970 * 1000;
    FREResult result;
    FREObject time;
    result = FRENewObjectFromDouble( timestamp, &time );
    if( result != FRE_OK ) return result;
    result = FRENewObject( "Date", 0, NULL, asDate, NULL );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asDate, "time", time, NULL);
    if( result != FRE_OK ) return result;
    return FRE_OK;
}
