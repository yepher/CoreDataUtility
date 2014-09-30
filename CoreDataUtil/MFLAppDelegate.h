//
//  MFLAppDelegate.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 11/3/11.
//  Copyright (c) 2011 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLCoreDataIntrospection.h"

@class GetInfoSheetController;

@class MFLMainWindowController;

extern NSString* const APPLICATIONS_DIR;

@interface MFLAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) MFLMainWindowController* mainWindowController;
@property (assign) IBOutlet NSWindow *window;

// This is used to prompt the user to save the file before exiting
@property (nonatomic) BOOL projectHasChanged;

- (IBAction)reportAnIssueAction:(id)sender;


@end
