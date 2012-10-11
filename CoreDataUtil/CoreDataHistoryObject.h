//
//  CoreDataHistoryObject.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/28/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHistoryObject : NSObject

@property (strong) NSString *entityName;
@property (strong) NSPredicate *predicate;

@end
