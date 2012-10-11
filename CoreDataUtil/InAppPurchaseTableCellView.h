//
//  InAppPurchaseTableCellView.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 7/2/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InAppPurchaseTableCellView : NSTableCellView

@property (strong) IBOutlet NSTextField* infoField;
@property (strong) IBOutlet NSTextField *priceField;

@end
