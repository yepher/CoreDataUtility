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

@implementation MFLCellBuilder

#pragma mark - 
#pragma mark Data Cell Helper

+ (MFLTextTableCellView* ) textCellWithString:(NSTableView *)tableView textToSet:(NSString*) textToSet owner:(id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSLeftTextAlignment];
    [[textCell infoField] setTextColor:[NSColor blackColor]];
    [[textCell infoField] setStringValue:textToSet];
    [textCell setToolTip:textToSet];
    
    return textCell;
}

+ (MFLTextTableCellView* ) numberCellWithString:(NSTableView *)tableView textToSet:(NSString*) textToSet owner: (id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSRightTextAlignment];
    [[textCell infoField] setTextColor:[NSColor blackColor]];
    [[textCell infoField] setStringValue:textToSet];
    [textCell setToolTip:textToSet];
    
    return textCell;
}

+ (MFLTextTableCellView* ) nullCell:(NSTableView *)tableView owner: (id) owner {
    
    MFLTextTableCellView* textCell = [tableView makeViewWithIdentifier:MFL_TEXT_CELL owner:owner];
    [[textCell infoField] setAlignment:NSRightTextAlignment];
    [[textCell infoField] setTextColor:[NSColor lightGrayColor]];
    
    [[textCell infoField] setStringValue:@"NULL"];
    
    return textCell;
}

+ (MFLButtonTableViewCell* ) objectCellWithString:(NSTableView *)tableView textToSet:(NSString*) textToSet owner:(id) owner {
    
    MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:owner];
    [[buttonCell infoField] setAlignment:NSRightTextAlignment];
    [[buttonCell infoField] setTextColor:[NSColor blackColor]];
    [[buttonCell infoField] setStringValue:textToSet];
    [buttonCell setToolTip:textToSet];
    
    return buttonCell;
}

@end
