//
//  ShowDetailSheetController.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/7/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLAppDelegate.h"
#import "EntityDataTableView.h"
#import "MFLMainWindowController.h"

@class MFLAppDelegate;
@class MFLMainWindowController;

@interface ShowDetailSheetController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    int sortType;
}

@property (strong) NSArray *detailInfo;
@property (weak) IBOutlet EntityDataTableView *detailTableView;
@property (weak) NSTableColumn *lastColumn;

- (IBAction)closeButtonAction:(id)sender;
- (void)show:(MFLMainWindowController *)sender:(NSArray *) initial;
- (void)reloadDetailTableView;
- (void)removeColumns;
- (NSArray*)entityColumnNames;
- (void)addTableColumnWithIdentifier:(NSString *)ident;
- (NSDateFormatterStyle)getNSDateFormatterStyle;
- (void)sortEntityData:(NSString *)columnId;

@end
