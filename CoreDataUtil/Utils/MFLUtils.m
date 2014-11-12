//
// Created by Joe Page on 11/12/14.
// Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import "MFLUtils.h"


@implementation MFLUtils { }

// return duration (in ms) from given startTime until now (for logging)
+ (NSNumber *)duration:(NSTimeInterval)startTime {
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    return @((int)((endTime - startTime) * 1000));
}

@end