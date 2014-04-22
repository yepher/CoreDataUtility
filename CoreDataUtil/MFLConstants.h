//
//  MFLConstants.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 1/4/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFLConstants : NSObject

extern NSString* const URL_FILE_BEGINNING;
extern NSString* const DATE_STYLE_KEY_NAME;

extern NSString* const MFL_TEXT_CELL;
extern NSString* const MFL_BUTTON_CELL;
extern NSString* const MFL_ENTITY_CELL;

extern NSString* const MFL_MOM_FILE_EXTENSION;

// Core Data Project File Keys
extern NSString* const MFL_PROJECT_FILE_VERSION_KEY;
extern NSString* const MFL_DB_FILE_KEY;
extern NSString* const MFL_MOM_FILE_KEY;
extern NSString* const MFL_DB_FORMAT_KEY;

// Core Data Pro project file extension
extern NSString* const MFL_COREDATA_PROJECT_EXTENSION;
extern NSString* const MFL_COREDATA_PROJECT_EXTENSION_UPERCASE;
extern NSString* const MFL_COREDATA_EDITOR_PROJECT_EXTENSION;


// In App Purchase Constants
extern NSString* const MFL_FULL_VERSION_IDENTIFIER;
extern NSString* const MFL_kProductPurchasedNotification;
extern NSString* const MFL_kProductPurchaseFailedNotification;
extern NSString* const MFL_kProductsLoadedNotification;

// These valued are used in CoreData project files
typedef NS_ENUM(NSInteger, MFL_StoreTypes) {
    MFL_SQLiteStoreType = 1,
    MFL_XMLStoreType = 2,
    MFL_BinaryStoreType = 3,
    MFL_InMemoryStoreType = 4,
};


typedef NS_ENUM(NSInteger, SortType)
{
    Ascending,
    Descending,
    Unsorted
};


@end
