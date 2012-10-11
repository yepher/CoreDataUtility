//
//  InAppPurchaseTableCellView.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 7/2/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "InAppPurchaseTableCellView.h"

@implementation InAppPurchaseTableCellView

@synthesize infoField = _infoField;
@synthesize priceField = _priceField;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
