//
//  TransformableDataTableViewCell.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 5/29/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TransformableDataTableViewCell : NSTableCellView

@property (strong) IBOutlet NSTextField* infoField;
@property (strong) IBOutlet NSButton* cellButton;

@end
