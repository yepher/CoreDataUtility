//
//  EntityTableViewCell.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/8/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "EntityTableViewCell.h"

#define RIGHT_MARGIN 3
#define X_RADIUS 7
#define ICON_PADDING 5

@implementation EntityTableViewCell

@synthesize cellText;
@synthesize cellLabel;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
    
    CGFloat iconWidth = [self drawIcon:cellFrame];
    CGFloat labelOriginX = [self drawLabel:cellFrame];
    [self drawText:cellFrame labelOrigin:labelOriginX iconWidth:iconWidth];
}

- (CGFloat)drawIcon:(NSRect)cellFrame
{
    NSImage *icon = [NSImage imageNamed:@"Entity_Small.png"];
    NSRect iconFrame = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.height - 1, cellFrame.size.height - 1);
    [icon drawInRect:iconFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    
    return [icon size].width;
}

- (CGFloat)drawLabel:(NSRect)cellFrame
{
    NSFont *labelTextFont = [NSFont systemFontOfSize:11];
    CGFloat labelTextWidth = [self widthOfString:self.cellLabel withFont:labelTextFont];
    CGFloat labelTextHeight = [self heightOfString:self.cellLabel withFont:labelTextFont];
    NSPoint labelTextOrigin = NSMakePoint(cellFrame.origin.x + cellFrame.size.width - labelTextWidth - X_RADIUS - RIGHT_MARGIN, cellFrame.origin.y + (cellFrame.size.height - labelTextHeight)/2);
    
    CGFloat labelOriginX = [self drawOval:labelTextOrigin];
    
    NSColor *labelTextColor;
    if ([self isHighlighted])
    {
        labelTextColor = [NSColor colorWithCalibratedRed:.53 green:.60 blue:.74 alpha:1.0];
    }
    else
    {
        labelTextColor = [NSColor whiteColor];
    }
    NSDictionary *labelTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         labelTextFont, NSFontAttributeName,
                                         labelTextColor, NSForegroundColorAttributeName, nil];
    [self.cellLabel drawAtPoint:labelTextOrigin withAttributes:labelTextAttributes];
    
    return labelOriginX;
}

- (CGFloat)drawOval:(NSPoint)labelTextOrigin
{
    NSFont *labelTextFont = [NSFont systemFontOfSize:11];
    CGFloat labelTextWidth = [self widthOfString:self.cellLabel withFont:labelTextFont];
    CGFloat labelTextHeight = [self heightOfString:self.cellLabel withFont:labelTextFont];
    
    NSBezierPath *badgePath = [NSBezierPath bezierPath];
    NSPoint line1Origin = NSMakePoint(labelTextOrigin.x - 1, labelTextOrigin.y - 0.5);
    NSPoint line1End = NSMakePoint(line1Origin.x + 2 + labelTextWidth, line1Origin.y);
    NSPoint line2Origin = NSMakePoint(line1Origin.x, line1Origin.y + 1 + labelTextHeight);
    NSPoint line2End = NSMakePoint(line1End.x, line2Origin.y);
    
    [badgePath moveToPoint:line1Origin];
    [badgePath lineToPoint:line1End];
    [badgePath appendBezierPathWithArcWithCenter:NSMakePoint(line1End.x, line1End.y + (line2End.y - line1End.y)/2) radius:(line2End.y - line1End.y)/2 startAngle:270 endAngle:90];
    [badgePath lineToPoint:line2Origin];
    [badgePath appendBezierPathWithArcWithCenter:NSMakePoint(line2Origin.x, line1Origin.y + (line2Origin.y - line1Origin.y)/2) radius:(line2Origin.y - line1Origin.y)/2 startAngle:90 endAngle:270];
    [badgePath closePath];
    
    if ([self isHighlighted])
    {
        [[NSColor whiteColor] set];
    }
    else
    {
        [[NSColor colorWithCalibratedRed:.53 green:.60 blue:.74 alpha:1.0] set];
    }
    [badgePath fill];
    [badgePath stroke];
    
    return line2Origin.x - (line2Origin.y - line1Origin.y)/2;
}

- (void)drawText:(NSRect)cellFrame labelOrigin:(CGFloat)labelOriginX iconWidth:(CGFloat)iconWidth
{
    NSFont *textFont = [NSFont systemFontOfSize:13];
    NSPoint textOrigin;
    textOrigin.x = cellFrame.origin.x + iconWidth + ICON_PADDING;
    textOrigin.y = cellFrame.origin.y;
    CGFloat maxWidth = labelOriginX - textOrigin.x;
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor blackColor], NSForegroundColorAttributeName,
                                    textFont, NSFontAttributeName, nil];
    
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
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
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

@end
