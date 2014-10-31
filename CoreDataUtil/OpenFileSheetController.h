//
//  OpenFileSheetController.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 5/17/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLAppDelegate.h"

typedef enum
{
    FileTab,
    ProcessTab,
    SimulatorTab
}TabName;

@class MFLAppDelegate;

@interface OpenFileSheetController : NSWindowController <NSTabViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    TabName currentTab;
    BOOL didSubmit;
}
@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSTextField *fileTabModelTextField;
@property (weak) IBOutlet NSTextField *fileTabPersistenceTextField;
@property (weak) IBOutlet NSPopUpButton *fileTabPersistenceFormat;
@property (weak) IBOutlet NSTextField *processTabModelTextField;
@property (weak) IBOutlet NSTextField *processTabPersistenceTextField;
@property (weak) IBOutlet NSPopUpButton *processTabPersistenceFormat;
@property (weak) IBOutlet NSTextField *simulatorTabModelTextField;
@property (weak) IBOutlet NSTextField *simulatorTabPersistenceTextField;
@property (weak) IBOutlet NSButton *fileTabPersistenceFileButton;
@property (weak) IBOutlet NSButton *fileTabSimulatorDirectoryButton;
@property (weak) IBOutlet NSButton *processTabPersistenceFileButton;
@property (weak) IBOutlet NSButton *processTabAppSupportButton;
@property (weak) IBOutlet NSButton *simulatorTabPersistenceFileButton;
@property (weak) IBOutlet NSButton *simulatorTabSimulatorDirectoryButton;
@property (weak) IBOutlet NSPopUpButton *simulatorTabPersistenceFormat;

@property (weak) IBOutlet NSButton *openButton;
@property (weak) IBOutlet NSComboBoxCell *processSelectorBox;
@property (strong) IBOutlet NSWindow *comboSelectorDialog;

- (IBAction)fileTabModelFileButtonAction:(id)sender;
- (IBAction)processTabRunningProcessButtonAction:(id)sender;
- (IBAction)simulatorTabSimulatorAppButtonAction:(id)sender;

- (IBAction)openButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)comboSelectOk:(id)sender;
- (IBAction)comboSelectCancel:(id)sender;

- (NSDictionary *)show:(NSWindow *)sender;
- (NSDictionary *)show:(NSWindow *)sender :(NSDictionary *)initialValues;

@end
