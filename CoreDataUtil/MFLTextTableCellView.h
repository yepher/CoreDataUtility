//
//  MFLTextTableCellView.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/21/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLMainWindowController.h"

@interface MFLTextTableCellView : NSTableCellView

@property (nonatomic) NSString *text;

@property (nonatomic) EViewType viewType;

@end
