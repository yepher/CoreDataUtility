//
//  FetchRequestInfoController.m
//  CoreDataUtil
//
//  Created by Denis Lebedev on 3/9/13.
//  Copyright (c) 2013 mFluent LLC. All rights reserved.
//

#import "FetchRequestInfoController.h"

@interface FetchRequestInfoController ()

@property (strong) NSFetchRequest *fetchRequest;
@property (strong) NSString *templateTitle;

@end

@implementation FetchRequestInfoController

- (void)initialize
{
	self.fetchTemplateNameTextField.stringValue = self.templateTitle;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[self initialize];
}

- (void)show:(NSWindow *)sender forFetchRequest:(NSFetchRequest *)initial title:(NSString *)title
{
	self.fetchRequest = initial;
	self.templateTitle = title;
    
    [NSApp beginSheet:self.window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}

- (IBAction)closeAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

@end
