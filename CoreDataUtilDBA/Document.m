//
//  Document.m
//  CoreDataUtilDBA
//
//  Created by Aliksandr Andrashuk on 11.03.13.
//  Copyright (c) 2013 mFluent LLC. All rights reserved.
//

#import "Document.h"
#import "OpenFileSheetController.h"

const float kOpenFileControllerShowDelay = 1.0;

@interface Document ()<OpenFileSheetControllerDelegate>
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet OpenFileSheetController *openFileController;

@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    [self.progressIndicator startAnimation:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kOpenFileControllerShowDelay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.openFileController = [[OpenFileSheetController alloc] initWithWindowNibName:@"OpenFileSheetController"];
        self.openFileController.delegate = self;
        
        [NSApp beginSheet:self.openFileController.window
           modalForWindow:self.windowForSheet
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:NULL];
    });
    
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark - Open file controller

- (void)closeOpenFileSheetController {
    [NSApp endSheet:self.openFileController.window];
    [self.openFileController close];
    self.openFileController = nil;
}

- (void)openFileSheetControllerDidCancel:(OpenFileSheetController *)controller {
    [self closeOpenFileSheetController];
    [self close];
}
- (void)openFileSheetController:(OpenFileSheetController *)controller didSelectModelURL:(NSURL *)modelURL storageURL:(NSURL *)storageURL {
    [self closeOpenFileSheetController];
    
    NSLog(@"Model URL: %@", modelURL);
    NSLog(@"Storage URL: %@", storageURL);
}

@end
