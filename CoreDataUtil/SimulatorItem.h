//
//  SimulatorItem.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 10/27/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MFLItemType) {
    MFLRootItem,
    MFLSimulatorItem,
    MFLAppItem
};

@interface SimulatorItem : NSObject


@property (nonatomic) MFLItemType itemType;
@property (nonatomic) NSString* relativePath;
@property (nonatomic) NSString* path;
@property (nonatomic) SimulatorItem* parent;
@property (nonatomic) NSMutableArray* children;
@property (nonatomic) NSDictionary* simInfo;

- (NSInteger) numberOfChildren;

+ (SimulatorItem*) rootItem;

- (SimulatorItem*) childAtIndex:(NSInteger)n;	// Invalid to call on leaf nodes

- (NSString *)fullPath;

- (NSString *)relativePath;

- (NSString*) label;

@end
