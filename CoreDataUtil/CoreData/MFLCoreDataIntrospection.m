//
//  MFLCoreDataIntrospection.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/18/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLCoreDataIntrospection.h"
#import "MFLUtils.h"

NSInteger const CORE_DATA_HISTORY_MAX = 100;

@interface MFLCoreDataIntrospection ()

@property (strong, nonatomic) NSManagedObjectModel* objModel;
@property (strong, nonatomic) NSMutableArray *entities;
@property (strong, nonatomic) NSArray *fetchRequests;

@property (strong, nonatomic) NSArray *entityData;

- (NSError *)errnoErrorWithReason:(NSString *)reason;

@end

@implementation MFLCoreDataIntrospection

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setStoreType:NSSQLiteStoreType]; // Default is SQL
        currentHistoryIndex = 0;
    }
    
    return self;
}


- (BOOL) isReady {
    if (self.momFileUrl != nil && self.dbFileUrl != nil) {
        return YES;
    }
    
    return NO;
}

- (void)loadObjectModel
{
    [self setEntities:[[NSMutableArray alloc] init]];
    [self setEntityData:nil];
    
    NSLog(@"momURL: [%@]", self.momFileUrl);
    NSManagedObjectModel* managedObjectModel = nil;
    @try {
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.momFileUrl];
        [self setObjModel:managedObjectModel];
    } @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        if (self.delegate != nil) {
            NSError* error = [self errnoErrorWithReason:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
            [self.delegate onLoadObjectModelFailedWithError:error];
        }
        // If we can't load object model than no need to continue
        return;
    }
    
    if (self.delegate != nil) {
        if (managedObjectModel) {
            // Success
            [self.delegate onLoadObjectModelSuccess];
        } else if (self.momFileUrl == nil) {
            NSLog(@"Could not load Object File because it was nil!");
            NSError* error = [self  errnoErrorWithReason:@"Could not load Object File because it was nil!"];
            [self.delegate onLoadObjectModelFailedWithError:error];
            return;
        } else {
            // Unknow Failure. Maybe the file was not a valid object model file
            NSLog(@"Could not load Object File: %@", self.momFileUrl);
            NSError* error = [self errnoErrorWithReason:[NSString stringWithFormat:@"Failed to load: %@. Make sure it is a valid Object Model file.", self.momFileUrl]];
            [self.delegate onLoadObjectModelFailedWithError:error];
            return;
        }
    }
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objModel];
    NSError *error = nil;

    @try {    
        if (coordinator != nil) {
            
            if (self.storeType == nil) {
                self.storeType = NSSQLiteStoreType;
            }
            
            if (![coordinator addPersistentStoreWithType:self.storeType
                                           configuration:nil
                                                     URL:self.dbFileUrl
                                                 options:nil
                                                   error:&error])
            {
                if (self.delegate != nil) {
                    [self.delegate onLoadPersistenceFailedWithError:error];
                }
                return;
            } else {
                if (self.delegate != nil) {
                    [self.delegate onLoadPersistenceSuccess];
                }
            }
            
            self.context = [[NSManagedObjectContext alloc] init];
            [self.context setPersistentStoreCoordinator:coordinator];
            error = nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"main: Failed to load persistence file. Caught %@: %@", [exception name], [exception reason]);
        if (self.delegate != nil) {
            NSError* error = [self errnoErrorWithReason:[NSString stringWithFormat:@"%@: %@", [exception name], [exception reason]]];
            [self.delegate onLoadPersistenceFailedWithError:error];
        }
    }
        
    NSArray *modelEntities = [self.objModel entities];
    for (NSEntityDescription* entityDescription in modelEntities)
    {
        [self.entities addObject:[entityDescription name]];
    }
    
	self.fetchRequests = [[self.objModel fetchRequestTemplatesByName] allKeys];
	
    error = nil;
    
    // we're opening a new file - clear the history. Don't add a new history object because an entity data table hasn't been populated yet
    self.coreDataHistory = nil;
}

- (void) reloadObjectModel
{
    [self loadObjectModel];
}

- (NSUInteger) fetchRequestCount
{
	return [self.fetchRequests count];
}
- (NSString*) fetchRequestAtIndex:(NSUInteger) index
{
	return self.fetchRequests[index];
}

- (NSFetchRequest*) fetchRequest:(NSUInteger) index
{
	return [self.objModel fetchRequestTemplateForName:self.fetchRequests[index]];
}

- (NSFetchRequest*) fetchRequestWithName:(NSString *) name
{
	return [self.objModel fetchRequestTemplateForName:name];
}

- (NSEntityDescription*) entityDescription:(NSUInteger) index {
    NSEntityDescription* entityDescription = [self.objModel entities][index];
    return entityDescription;
}

- (NSEntityDescription *)entityDescriptionForName:(NSString *)entityName
{
    NSArray *entities = [self.objModel entities];
    for (NSEntityDescription* entityDescription in entities)
    {
        if ([[entityDescription name] isEqualToString:entityName])
        {
            return entityDescription;
        }
    }
    
    return nil;
}

// TODO: find a better name for this method.
- (NSArray*) entityFieldNames:(NSString*) entityName
{
    NSMutableArray* columnNames = [NSMutableArray arrayWithCapacity:0];
    //Dump object Meta data graph
    NSArray *entities = [self.objModel entities];
    for (NSEntityDescription* entityDescription in entities)
    {
        if ([[entityDescription name] isEqualToString:entityName])
        {
            for (NSPropertyDescription *property in entityDescription)
            {
                //NSLog(@"Prop Name: [%@]", [property name]);                
                [columnNames addObject:[property name]];
            }
            return columnNames;
        }
    }
    
    return columnNames;
}

- (NSArray*) fetchObjectsByEntityName: (NSString*) entityName
{
    NSError *error = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray*  fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (NSArray*) fetchObjectsByEntityName: (NSString*) entityName :(NSPredicate*) predicate {
    NSError *error = nil;
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSArray*  fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (void) applyPredicate: (NSString*) entityName predicate:(NSPredicate*) predicate {
    
    self.entityData = [self fetchObjectsByEntityName:entityName: predicate];
}

- (void) executeFetch: (NSFetchRequest *)fetch {
	self.entityData = [self.context executeFetchRequest:fetch error:NULL];
}

- (void)sortEntityData:(NSString *)fieldName {
    BOOL isStringColumn = NO;

    // Put values for selected column into a dictionary with their current row number as the key
    NSMutableDictionary *columnObjs = [[NSMutableDictionary alloc] initWithCapacity:[self.entityData count]];
    NSInteger rowNum = 0;
    for (NSArray *row in self.entityData) {
        id obj = [row valueForKey:fieldName];
        // check if this is column is NSString
        if (!isStringColumn && [obj isKindOfClass:[NSString class]]) {
            isStringColumn = YES;
        }

        id valueObj = obj;

        // change values of non-native/sortable objects for easier sorting
        if (obj == nil) {
            valueObj = [NSNull null];
        }
        if ([obj isKindOfClass:[NSSet class]]) {
            NSSet* mySet = obj;
            valueObj = @([mySet count]);
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray* myArray = obj;
            valueObj = @([myArray count]);
        }
        else if ([obj isKindOfClass:[NSManagedObject class]]) {
            valueObj = [[obj entity] name];
        }
        else if ([obj isKindOfClass:[NSData class]]) {
            NSData* data = (NSData*) obj;
            valueObj = @([data length]);
        }

        // add valueObj to array for sorting
        columnObjs[@(rowNum)] = valueObj;
        rowNum++;
    }
    
    // sort!
    NSArray *sortedColumns = [columnObjs keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // handle nil objects by putting them above any non-nil object
        if (obj1 == NSNull.null && obj2 == NSNull.null) {
            return NSOrderedSame;
        }
        else if (obj1 == NSNull.null) {
            return NSOrderedAscending;
        }
        else if (obj2 == NSNull.null) {
            return NSOrderedDescending;
        }
        // both objects are NOT nil
        else if (isStringColumn) {
            return [obj1 caseInsensitiveCompare:obj2];
        }
        else {
            return [obj1 compare:obj2];
        }
    }];


    // Move the sorted values back into an array
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSNumber *oldRowNum in sortedColumns)
    {
        [temp addObject:(self.entityData)[(NSUInteger)[oldRowNum integerValue]]];
    }
    self.entityData = temp;
}

- (NSArray*) keyPathsForEntity:(NSEntityDescription*) entityDescription {
    
    NSMutableArray* keyPaths = [NSMutableArray arrayWithCapacity:0];
    if (entityDescription == nil) {
        return keyPaths;
    }
    
    for (NSAttributeDescription *property in entityDescription) {
        //NSLog(@"Prop Name: [%@] - [%@]", [property description], [property class]);
        
        /** 
         Possible Attribute Types
         ------------------
         NSUndefinedAttributeType       = 0,
         NSInteger16AttributeType       = 100,
         NSInteger32AttributeType       = 200,
         NSInteger64AttributeType       = 300,
         NSDecimalAttributeType         = 400,
         NSDoubleAttributeType          = 500,
         NSFloatAttributeType           = 600,
         NSStringAttributeType          = 700,
         NSBooleanAttributeType         = 800,
         NSDateAttributeType            = 900,
         
         // Not sure how to support the following attribute types
         NSBinaryDataAttributeType      = 1000,
         NSTransformableAttributeType   = 1800,
         NSObjectIDAttributeType        = 2000
         
         **/
        if ([property isKindOfClass:NSAttributeDescription.class] && [property attributeType] == NSBinaryDataAttributeType) {
            // Not sure how to handle NSTransformableAttributeType so exlude from key paths
            //NSLog(@"Exclude NSTransformableAttributeType: %@", property);
            
        } else if ([property isKindOfClass:NSAttributeDescription.class] && [property attributeType] == NSTransformableAttributeType) {
            /* 
             If the attribute is of NSTransformableAttributeType, the attributeValueClassName
             must be set or attribute value class must implement NSCopying.
             */
            
            // Not sure how to handle NSObjectIDAttributeType so exlude from key paths
            //NSLog(@"Exclude NSObjectIDAttributeType: %@", property);
            
        } else if ([property isKindOfClass:NSAttributeDescription.class] && [property attributeType] == NSObjectIDAttributeType) {
            // Not sure how to handle NSBinaryDataAttributeType so exlude from key paths
            //NSLog(@"Exclude NSBinaryDataAttributeType: %@", property);
            
        } else if ([property isKindOfClass:NSAttributeDescription.class]) {
            [keyPaths addObject:[property name]];
        } else {
            // Need to handle NSRelationshipDescription
            
            NSLog(@"Unhandled NSAttributeDescription (%@)", [property entity]);
        }
        
    }
    
    return keyPaths;
}
                              
- (NSError *)errnoErrorWithReason:(NSString *)reason {
    NSString *errMsg = @(strerror(errno));
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errMsg,
                            NSLocalizedFailureReasonErrorKey: reason};

    return [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:userInfo];
}
                              
- (NSUndoManager *)undoManager {
    return [[self context] undoManager];
}

- (NSUInteger) entityCount {
    if (self.entities == nil) {
        return 0;
    }
    
    return [self.entities count];
}

- (void) clearEntityData {
    self.entityData = nil;
}

- (void) loadEntityDataAtIndex: (NSUInteger) index {
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    self.entityData = [self fetchObjectsByEntityName:[self entityAtIndex:index]];
    NSLog(@"loadEntityDataAtIndex: %@ms", [MFLUtils duration:startTime]);
}

- (NSString*) entityAtIndex:(NSUInteger) index {
    return (self.entities)[index];
}

- (NSUInteger) entityDataCountAtIndex: (NSUInteger) index
{
    NSArray* data = [self fetchObjectsByEntityName:[self entityAtIndex:index]];
    return [data count];
}

- (NSUInteger) entityDataCount {
    if (self.entityData == nil) {
        return 0;
    }
    
    return [self.entityData count];
}

- (NSArray*) getDataAtRow: (NSUInteger) row {
    if (row >= 0 && row < [self entityDataCount]) {
        return (self.entityData)[row];
    }
    else {
        NSLog(@"getDataAtRow: bad row:%d", (int)row);
        return nil;
    }
}

- (NSInteger)getCurrentHistoryIndex
{
    return currentHistoryIndex;
}

- (void)setCurrentHistoryIndex:(NSInteger)currentIndex
{
    currentHistoryIndex = currentIndex;
}

- (void)updateCoreDataHistory:(NSString *)name predicate:(NSPredicate *)predicate objectType:(MFLObjectType)type
{
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    if (self.coreDataHistory == nil)
    {
        self.coreDataHistory = [[NSMutableArray alloc] initWithCapacity:CORE_DATA_HISTORY_MAX];
    }
    
    CoreDataHistoryObject *coreDataHistoryObj = [[CoreDataHistoryObject alloc] init];
    [coreDataHistoryObj setName:name];
    [coreDataHistoryObj setPredicate:predicate];
	[coreDataHistoryObj setType:type];
    [self.coreDataHistory insertObject:coreDataHistoryObj atIndex:currentHistoryIndex];
    
    // handle the case where we are in the middle of the history array and we insert a new history item
    if (currentHistoryIndex > 0)
    {
        for (int i = 0; i < currentHistoryIndex; i++)
        {
            [self.coreDataHistory removeObjectAtIndex:0];
        }
        
        currentHistoryIndex = 0;
    }
    
    // handle any duplicate objects that are side-by-side
    if (([self.coreDataHistory count] >= 2) && (currentHistoryIndex <= [self.coreDataHistory count] - 2))
    {
        CoreDataHistoryObject *currentObj = self.coreDataHistory[currentHistoryIndex];
        CoreDataHistoryObject *nextObj = self.coreDataHistory[currentHistoryIndex + 1];
        if ([currentObj isEqualTo:nextObj] || (currentObj.type == nextObj.type && currentObj.type == MFLObjectTypeEntity &&
            [[self fetchObjectsByEntityName:currentObj.name :currentObj.predicate] isEqualTo:[self fetchObjectsByEntityName:nextObj.name :nextObj.predicate]]))
        {
            [self.coreDataHistory removeObjectAtIndex:currentHistoryIndex + 1];
        }
    }
    NSLog(@"updateCoreDataHistory: %@, %@ms", name, [MFLUtils duration:startTime]);
}

@end
