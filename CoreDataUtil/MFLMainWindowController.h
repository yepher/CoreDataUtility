//
//  MFLMainWindowController.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLCoreDataIntrospection.h"
#import "CoreDataHistoryObject.h"

#import "EntityTableView.h"

@class EntityTableView;
@class EntityDataTableView;

@interface MFLMainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, MFLCoreDataIntrospectionDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSSplitViewDelegate, EntityTableViewDataSource>

@property (weak) IBOutlet EntityTableView *dataSourceList;
@property (weak) IBOutlet EntityDataTableView *entityContentTable;
@property (weak) IBOutlet NSSegmentedControl* userSelecteddateFormat;
@property (unsafe_unretained) IBOutlet NSWindow *predicateSheet;
@property (weak) IBOutlet NSMatrix *preferenceSheetMatrix;
@property (weak) IBOutlet NSTextField *generatedPredicateLabel;
@property (weak) IBOutlet NSSegmentedControl *historySegmentedControl;

//- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (BOOL) openFiles:(NSURL*) momFile persistenceFile:(NSURL*) persistenceFile persistenceType: (NSInteger) persistenceType;

- (NSURL*) momFileUrl;
- (NSURL*) persistenceFileUrl;
- (NSInteger) persistenceFileFormat;

- (id)getValueObjFromDataRows:(NSTableView *)tableView :(NSInteger)row :(NSTableColumn *)tableColumn;

/**
 Displays the info sheet for the currently selected entity
 **/
- (void)getInfoAction;

@end
