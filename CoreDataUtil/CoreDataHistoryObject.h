//
//  CoreDataHistoryObject.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/28/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MFLObjectType) {
	MFLObjectTypeEntity,
	MFLObjectTypeFetchRequest
};

@interface CoreDataHistoryObject : NSObject

@property (strong) NSString *name;
@property (strong) NSPredicate *predicate;
@property (assign) MFLObjectType type;

@end
