//
//  GetInfoSheetController.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 5/30/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLAppDelegate.h"

@class MFLAppDelegate;

@interface GetInfoSheetController : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *entityNameTextField;
@property (weak) IBOutlet NSTableView *entityUserInfoTableView;
@property (weak) IBOutlet NSOutlineView *entityDescriptionOutlineView;

- (IBAction)closeAction:(id)sender;

- (void)show:(NSWindow *)sender :(NSEntityDescription *) initial;

@end
