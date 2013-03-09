//
//  MFLConstants.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#ifndef CoreDataUtil_MFLConstants_h
#define CoreDataUtil_MFLConstants_h

#define URL_FILE_BEGINNING @"file://localhost"
#define DATE_STYLE_KEY_NAME @"dateStyleKey"

#define MFL_TEXT_CELL @"MFLTextTableViewCell"
#define MFL_BUTTON_CELL @"MFLButtonTableViewCell"
#define MFL_ENTITY_CELL @"MFLEntityTableCellView"

#define MFL_MOM_FILE_EXTENSION @".mom"

// Core Data Project File Keys
#define MFL_PROJECT_FILE_VERSION_KEY @"v"
#define MFL_DB_FILE_KEY @"storeFilePath"
#define MFL_MOM_FILE_KEY @"modelFilePath"
#define MFL_DB_FORMAT_KEY @"storeFormat"

// These valued are used in CoreData project files
#define MFL_SQLiteStoreType   1
#define MFL_XMLStoreType      2
#define MFL_BinaryStoreType   3
#define MFL_InMemoryStoreType 4

// Core Data Pro project file extension
#define MFL_COREDATA_PROJECT_EXTENSION @"cdp"
#define MFL_COREDATA_PROJECT_EXTENSION_UPERCASE @"CDP"
#define MFL_COREDATA_EDITOR_PROJECT_EXTENSION @"coredataeditor"


// In App Purchase Constants
#define MFL_FULL_VERSION_IDENTIFIER @"com.fluentfactory.coredatapro.allfeatures"
#define MFL_kProductPurchasedNotification       @"ProductPurchased"
#define MFL_kProductPurchaseFailedNotification  @"ProductPurchaseFailed"
#define MFL_kProductsLoadedNotification @"ProductsLoaded"

typedef enum
{
    Ascending,
    Descending,
    Unsorted
}SortType;


#endif
