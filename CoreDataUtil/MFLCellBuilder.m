//
//  MFLCellBuilder.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLCellBuilder.h"
#import "MFLConstants.h"
#import "MFLTextTableCellView.h"
#import "MFLButtonTableViewCell.h"
#import "InAppPurchaseTableCellView.h"

@implementation MFLCellBuilder

#pragma mark - 
#pragma mark Data Cell Helper

+ (MFLTextTableCellView* ) textCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSLeftTextAlignment];
    [[textCell infoField] setTextColor:[NSColor blackColor]];
    [[textCell infoField] setStringValue:textToSet];
    [textCell setToolTip:textToSet];
    
    return textCell;
}

+ (MFLTextTableCellView* ) numberCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSRightTextAlignment];
    [[textCell infoField] setTextColor:[NSColor blackColor]];
    [[textCell infoField] setStringValue:textToSet];
    [textCell setToolTip:textToSet];
    
    return textCell;
}

+ (MFLTextTableCellView* ) nullCell:(NSTableView *)tableView: (id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSRightTextAlignment];
    [[textCell infoField] setTextColor:[NSColor lightGrayColor]];
    
    [[textCell infoField] setStringValue:@"NULL"];
    
    return textCell;
}

+ (MFLButtonTableViewCell* ) objectCellWithString:(NSTableView *)tableView: (NSString*) textToSet: (id) owner {
    
    MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:owner];
    [[buttonCell infoField] setAlignment:NSRightTextAlignment];
    [[buttonCell infoField] setTextColor:[NSColor blackColor]];
    [[buttonCell infoField] setStringValue:textToSet];
    [buttonCell setToolTip:textToSet];
    
    return buttonCell;
}

+ (InAppPurchaseTableCellView *)inAppPurchaseCellWithString:(NSTableView *)tableView :(NSString *)textToSet :(NSString *)priceText :(NSInteger)row :(id)owner
{
    InAppPurchaseTableCellView *cell = [tableView makeViewWithIdentifier:IN_APP_CELL owner:owner];
    
    // set value text
    [[cell infoField] setAlignment:NSLeftTextAlignment];
    [[cell infoField] setTextColor:[NSColor blackColor]];
    [[cell infoField] setStringValue:textToSet];
    [cell setToolTip:textToSet];
    
    // set price text
    [[cell priceField] setAlignment:NSLeftTextAlignment];
    [[cell priceField] setTextColor:[NSColor grayColor]];
    [[cell priceField] setStringValue:priceText];
    
    // set up button
    NSButton *buyButton = [[NSButton alloc] init];
    buyButton.frame = CGRectMake(0, 0, 72, 37);
    [buyButton setTitle:@"Buy"];
    buyButton.tag = row;
    [buyButton setTarget:owner];
    [buyButton setAction:@selector(buyButtonTapped:)];
    
    return cell;
}

@end
