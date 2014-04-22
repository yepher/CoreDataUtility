//
//  MFLEntityTableCellView.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/21/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLEntityTableCellView.h"

NSInteger const RIGHT_MARGIN = 3;
NSInteger const X_RADIUS = 7;
NSInteger const ICON_PADDING = 5;

@implementation MFLEntityTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}


- (NSMutableArray *)splitStringIntoCharArray:(NSString *)string
{
    NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:[string length]];
    for (int i = 0; i < [string length]; i++)
    {
        NSString *iChar = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        [chars addObject:iChar];
    }
    
    return chars;
}




- (void)xdrawRect:(NSRect)dirtyRect
{
        
}


@end
