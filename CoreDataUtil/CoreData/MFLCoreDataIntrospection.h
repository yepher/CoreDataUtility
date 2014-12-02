//
//  MFLCoreDataIntrospection.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/18/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFLCoreDataCommon.h"
#import "CoreDataHistoryObject.h"

@protocol MFLCoreDataIntrospectionDelegate <NSObject>

- (void) onLoadObjectModelSuccess;
- (void) onLoadObjectModelFailedWithError:(NSError*) error;

- (void) onLoadPersistenceSuccess;
- (void) onLoadPersistenceFailedWithError:(NSError*) error;

@end

@interface MFLCoreDataIntrospection : MFLCoreDataCommon
{
    NSInteger currentHistoryIndex;
}

@property (nonatomic, strong) id <MFLCoreDataIntrospectionDelegate> delegate;

@property (strong, nonatomic) NSString* storeType;
@property (nonatomic) NSDateFormatterStyle dateStyle;
@property (strong) NSURL *momFileUrl;
@property (strong) NSURL *dbFileUrl;
@property (strong) NSMutableArray *coreDataHistory;

- (void) loadObjectModel;
- (void) reloadObjectModel;
- (void) clearEntityData;

- (NSUInteger) entityCount;
- (NSString*) entityAtIndex:(NSUInteger) index;

- (NSUInteger) fetchRequestCount;
- (NSString*) fetchRequestAtIndex:(NSUInteger) index;
- (NSFetchRequest*) fetchRequest:(NSUInteger) index;
- (NSFetchRequest*) fetchRequestWithName:(NSString *) name;

- (NSArray*) entityFieldNames:(NSString*) entityName;
- (NSEntityDescription*) entityDescription:(NSUInteger) index;
- (NSEntityDescription *)entityDescriptionForName:(NSString *)entityName;
- (NSArray*) fetchObjectsByEntityName: (NSString*) entityName;
- (NSArray*) fetchObjectsByEntityName: (NSString*) entityName :(NSPredicate*) predicate;

- (void) loadEntityDataAtIndex: (NSUInteger) index;
- (NSUInteger) entityDataCountAtIndex: (NSUInteger) index;
- (NSUInteger) entityDataCount;
- (NSArray*) getDataAtRow: (NSUInteger) row;
- (NSArray*) keyPathsForEntity:(NSEntityDescription*) entityDescription;

- (NSUndoManager*) undoManager;

- (void) applyPredicate: (NSString*) entityName  predicate:(NSPredicate*) predicate;
- (void) executeFetch: (NSFetchRequest *)fetch;

- (void)sortEntityData:(NSString *)fieldName;
//+ (id)getDisplayValueForObject:(id)obj;
- (NSInteger)getCurrentHistoryIndex;
- (void)setCurrentHistoryIndex:(NSInteger)currentIndex;
- (void)updateCoreDataHistory:(NSString *)name predicate:(NSPredicate *)predicate objectType:(MFLObjectType)type;

@end
