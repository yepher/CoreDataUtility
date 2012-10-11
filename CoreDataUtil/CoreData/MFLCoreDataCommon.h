//
//  MFLCoreDataCommon.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/20/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFLCoreDataCommon : NSObject 

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSURL *)applicationFilesDirectory;
@end
