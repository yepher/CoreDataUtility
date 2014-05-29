//
//  ObjectInfoController.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 5/29/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import "ObjectInfoController.h"

@interface ObjectInfoController ()

@property (strong) NSString* objectDescriptionText;

@end

@implementation ObjectInfoController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self objectDescription] setString:self.objectDescriptionText];
    
}


- (IBAction)closeAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

- (void)show:(NSWindow *)sender objectDescription:(NSString*) theDescription;
{
    self.objectDescriptionText = theDescription;
    
    [NSApp beginSheet:self.window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
	// sheet is up here...
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}


@end
