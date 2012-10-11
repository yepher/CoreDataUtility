//
//  EntityTableViewCell.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/8/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EntityTableViewCell : NSTextFieldCell

@property (strong) NSString *cellText;
@property (strong) NSString *cellLabel;

- (CGFloat)drawIcon:(NSRect)cellFrame;
- (CGFloat)drawLabel:(NSRect)cellFrame;
- (CGFloat)drawOval:(NSPoint)labelTextOrigin;
- (void)drawText:(NSRect)cellFrame labelOrigin:(CGFloat)labelOriginX iconWidth:(CGFloat)iconWidth;
- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;
- (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font;
- (NSMutableArray *)splitStringIntoCharArray:(NSString *)string;

@end
