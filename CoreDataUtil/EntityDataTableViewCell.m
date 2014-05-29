//
//  EntityDataTableViewCell.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/19/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "EntityDataTableViewCell.h"
#import "CoreDataUtilityStyle.h"

NSUInteger const MFL_CELL_ICON_MARGIN = 3;

@interface EntityDataTableViewCell ()

- (void)drawButton:(NSRect)cellFrame withView:(NSView *)controlView;
- (void)drawIcon:(NSRect)cellFrame;
- (void)drawText:(NSRect)cellFrame;
- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;
- (NSMutableArray *)splitStringIntoCharArray:(NSString *)string;

@end

@implementation EntityDataTableViewCell


- (CellType)getCellType
{
    return cellType;
}

- (void)setCellType:(CellType)type
{
    cellType = type;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
    
    // draw button (icon buttons in Entity Data Table View)
    if (cellType == CellTypeManagedObject || cellType == CellTypeCollection)
    {
        [self drawButton:cellFrame withView:controlView];
    }
    
    // draw icon (outline view cells in Get Info)
    if (cellType == OutlineCellTypeBinary || cellType == OutlineCellTypeBoolean || cellType == OutlineCellTypeDate || cellType == OutlineCellTypeNumber || 
        cellType == OutlineCellTypeObject || cellType == OutlineCellTypeString)
    {
        [self drawIcon:cellFrame];
    }
    
    [self drawText:cellFrame];
}

- (void)drawButton:(NSRect)cellFrame withView:(NSView *)controlView
{
    NSImage *icon;
    if (cellType == CellTypeManagedObject)
    {
        icon = [CoreDataUtilityStyle imageOfEntity];
    }
    else // collection
    {
        icon = [CoreDataUtilityStyle imageOfEntitySet];
    }
    
    NSRect iconFrame = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.height - 1, cellFrame.size.height - 1);
    NSButton *button = [[NSButton alloc] initWithFrame:iconFrame];
    [controlView addSubview:button];
    [button setButtonType:NSMomentaryPushInButton];
    [button setImagePosition:NSImageOnly];
    [button setBezelStyle:NSSmallSquareBezelStyle];
    [button setImage:icon];
    [button setAction:@selector(buttonClicked:)];
}

- (void)drawIcon:(NSRect)cellFrame
{
    NSImage *icon;
    if (cellType == OutlineCellTypeBinary)
    {
        icon = [CoreDataUtilityStyle imageOfBinary];
    }
    else if (cellType == OutlineCellTypeBoolean)
    {
        icon = [CoreDataUtilityStyle imageOfBoolean];
    }
    else if (cellType == OutlineCellTypeDate)
    {
        icon =  [CoreDataUtilityStyle imageOfDate];
    }
    else if (cellType == OutlineCellTypeNumber)
    {
        icon = [CoreDataUtilityStyle imageOfNumber];
    }
    else if (cellType == OutlineCellTypeObject)
    {
        icon = [CoreDataUtilityStyle imageOfAnObject];
    }
    else //OutlineCellTypeString
    {
        icon = [CoreDataUtilityStyle imageOfAString];
    }
    
    NSRect iconFrame = NSMakeRect(cellFrame.origin.x + MFL_CELL_ICON_MARGIN, cellFrame.origin.y, cellFrame.size.height - 1, cellFrame.size.height - 1);
    [icon drawInRect:iconFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
}

- (void)drawText:(NSRect)cellFrame
{
    NSFont *textFont = [NSFont systemFontOfSize:13];
    NSPoint textOrigin;
    CGFloat maxWidth;
    if (cellType == CellTypeManagedObject || cellType == CellTypeCollection)
    {
        textOrigin.x = cellFrame.origin.x + cellFrame.size.height + 1;
        maxWidth = cellFrame.size.width - cellFrame.size.height - 1;
    }
    else if (cellType == OutlineCellTypeBinary || cellType == OutlineCellTypeBoolean || cellType == OutlineCellTypeDate || cellType == OutlineCellTypeNumber || 
             cellType == OutlineCellTypeObject || cellType == OutlineCellTypeString)
    {
        textOrigin.x = cellFrame.origin.x + cellFrame.size.height + MFL_CELL_ICON_MARGIN*2;
        maxWidth = cellFrame.size.width - cellFrame.size.height - MFL_CELL_ICON_MARGIN*2;
    }
    else
    {
        textOrigin.x = cellFrame.origin.x + 1;
        maxWidth = cellFrame.size.width;
    }
    textOrigin.y = cellFrame.origin.y;
    
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName: [NSColor blackColor],
                                    NSFontAttributeName: textFont};
    
    NSString *text = self.cellText;
    if ([self widthOfString:text withFont:textFont] >= maxWidth)
    {
        CGFloat newMaxWidth = maxWidth - [self widthOfString:@"..." withFont:textFont] - 1;
        NSArray *chars = [self splitStringIntoCharArray:text];
        NSMutableString *temp = [[NSMutableString alloc] init];
        for (NSString *iChar in chars)
        {
            [temp appendString:iChar];
            if ([self widthOfString:temp withFont:textFont] >= newMaxWidth)
            {
                [temp deleteCharactersInRange:NSMakeRange([temp length] - 1, 1)];
                [temp appendString:@"..."];
                break;
            }
        }
        
        text = temp;
    }
    
    [text drawAtPoint:textOrigin withAttributes:textAttributes];
}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
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

@end
