//
//  InAppPurchaseWindowController.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/29/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFLAppDelegate.h"
#import "MFLInAppPurchaseHelperSubclass.h"
#import "InAppPurchaseTableCellView.h"
#import "MFLCellBuilder.h"

@class MFLAppDelegate;

@interface InAppPurchaseWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *inAppPurchaseTableView;

- (IBAction)inAppPurchaseCancelButtonAction:(id)sender;

- (void)show:(NSWindow *)sender;

@end
