//
//  MFLBuild.m
//  BriteIM
//
//  Created by Chris Wilson on 1/30/14.
//  Copyright (c) 2014 Chris Wilson All rights reserved.

/********************
   WARNING: this file is automatically updated by XCode during the build. Any uncommited changes to this file
       will be lost during the build process.
 ********************/

#import "MFLBuild.h"

@implementation MFLBuild

NSString *const MFL_VERSION = @"APP_VERSION"
#ifdef DEBUG
// Show "d" after version if this is a DEBUG build
@" d"
#endif
;

NSString *const MFL_BUILD_VERSION = @"BUILD_GENERATED_VERSION";

NSString *const MFL_GIT_HASH = @"BUILD_GENERATED_GIT_HASH";

NSString *const MFL_GIT_LAST = @"BUILD_LAST_COMMIT";

NSString *const MFL_BUILD_DATE = @"BUILD_GENERATED_DATE";

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

NSString *const MFL_PLATFORM = @"ios";

#ifdef DEBUG
NSInteger const MFL_DEVICE_TYPE = 4; // IOS device - sandbox APNS
#else
NSInteger const MFL_DEVICE_TYPE = 6; // IOS device - production APNS
#endif

#else

NSString *const MFL_PLATFORM = @"mac";

#ifdef DEBUG
NSInteger const MFL_DEVICE_TYPE = 5; // MAC device - sandbox APNS
#else
NSInteger const MFL_DEVICE_TYPE = 7; // MAC device - production APNS
#endif

#endif



@end
