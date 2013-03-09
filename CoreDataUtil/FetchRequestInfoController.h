//
//  FetchRequestInfoController.h
//  CoreDataUtil
//
//  Created by Denis Lebedev on 3/9/13.
//  Copyright (c) 2013 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FetchRequestInfoController : NSWindowController

@property (weak) IBOutlet NSTextField *fetchTemplateNameTextField;

- (void)show:(NSWindow *)sender forFetchRequest:(NSFetchRequest *)initial title:(NSString *)title;
- (IBAction)closeAction:(id)sender;

@end
