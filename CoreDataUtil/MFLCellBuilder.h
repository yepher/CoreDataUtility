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

+ (MFLTextTableCellView* ) textCellWithString:(NSTableView *)tableView textToSet:(NSString*) textToSet owner:(id) owner;
+ (MFLTextTableCellView* ) numberCellWithString:(NSTableView *)tableView textToSet: (NSString*) textToSet owner:(id) owner;
+ (MFLTextTableCellView* ) nullCell:(NSTableView *)tableView owner:(id) owner;
+ (MFLButtonTableViewCell* ) objectCellWithString:(NSTableView *)tableView textToSet:(NSString*) textToSet owner:(id) owner;
+ (InAppPurchaseTableCellView *)inAppPurchaseCellWithString:(NSTableView *)tableView :(NSString *)textToSet :(NSString *)priceText :(NSInteger)row :(id)owner;

@end
