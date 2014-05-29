//
//  MFLConstants.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 1/4/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import "MFLConstants.h"

@implementation MFLConstants

NSString* const URL_FILE_BEGINNING = @"file://localhost";
NSString* const DATE_STYLE_KEY_NAME = @"dateStyleKey";

NSString* const MFL_TEXT_CELL = @"MFLTextTableViewCell";
NSString* const MFL_BUTTON_CELL = @"MFLButtonTableViewCell";
NSString* const MFL_TRANSFORM_CELL = @"TransformableDataTableViewCell";
NSString* const MFL_ENTITY_CELL = @"MFLEntityTableCellView";

NSString* const MFL_MOM_FILE_EXTENSION = @".mom";

// Core Data Project File Keys
NSString* const MFL_PROJECT_FILE_VERSION_KEY = @"v";
NSString* const MFL_DB_FILE_KEY = @"storeFilePath";
NSString* const MFL_MOM_FILE_KEY = @"modelFilePath";
NSString* const MFL_DB_FORMAT_KEY = @"storeFormat";

// Core Data Pro project file extension
NSString* const MFL_COREDATA_PROJECT_EXTENSION = @"cdp";
NSString* const MFL_COREDATA_PROJECT_EXTENSION_UPERCASE = @"CDP";
NSString* const MFL_COREDATA_EDITOR_PROJECT_EXTENSION = @"coredataeditor";


// In App Purchase Constants
NSString* const MFL_FULL_VERSION_IDENTIFIER = @"com.fluentfactory.coredatapro.allfeatures";
NSString* const MFL_kProductPurchasedNotification = @"ProductPurchased";
NSString* const MFL_kProductPurchaseFailedNotification = @"ProductPurchaseFailed";
NSString* const MFL_kProductsLoadedNotification = @"ProductsLoaded";


@end
