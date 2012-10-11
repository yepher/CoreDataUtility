//
//  MFLCellBuilder.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFLInAppPurchaseHelperSubclass.h"

@class MFLTextTableCellView;
@class MFLButtonTableViewCell;
@class InAppPurchaseTableCellView;

@interface MFLCellBuilder : NSObject

+ (MFLTextTableCellView* ) textCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner;
+ (MFLTextTableCellView* ) numberCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner;
+ (MFLTextTableCellView* ) nullCell:(NSTableView *)tableView: (id) owner;
+ (MFLButtonTableViewCell* ) objectCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner;
+ (InAppPurchaseTableCellView *)inAppPurchaseCellWithString:(NSTableView *)tableView :(NSString *)textToSet :(NSString *)priceText :(NSInteger)row :(id)owner;

@end
