//
//  MFLEntityTableCellView.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/21/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFLEntityTableCellView : NSTableCellView

@property (strong) IBOutlet NSTextField* label;
@property (strong) IBOutlet NSButton* countButton;

@end
