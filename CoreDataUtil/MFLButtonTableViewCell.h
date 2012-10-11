//
//  MFLButtonTableViewCell.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/21/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFLButtonTableViewCell : NSTableCellView

@property (strong) IBOutlet NSTextField* infoField;
@property (strong) IBOutlet NSButton* cellButton;

@end
