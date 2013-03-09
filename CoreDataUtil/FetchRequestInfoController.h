//
//  FetchRequestInfoController.h
//  CoreDataUtil
//
//  Created by Denis Lebedev on 3/9/13.
//  Copyright (c) 2013 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FetchRequestInfoController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *fetchTemplateNameTextField;
@property (weak) IBOutlet NSButton *entityButton;
@property (weak) IBOutlet NSTableView *fetchPropertiesTableView;
@property (weak) IBOutlet NSTextField *predicateTextField;

- (void)show:(NSWindow *)sender forFetchRequest:(NSFetchRequest *)initial title:(NSString *)title;

- (IBAction)closeAction:(id)sender;
- (IBAction)entityClickAction:(NSButton *)sender;

@end
