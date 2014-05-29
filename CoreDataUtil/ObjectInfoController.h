//
//  ObjectInfoController.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 5/29/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ObjectInfoController : NSWindowController

@property (unsafe_unretained) IBOutlet NSTextView *objectDescription;


- (IBAction)closeAction:(id)sender;

- (void)show:(NSWindow *)sender objectDescription:(NSString*) description;


@end
