//
//  MFLTextTableCellView.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/21/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLTextTableCellView.h"

static const int PADDING_X = 5;

static const int PADDING_Y = 2;

static NSString *const NIL_VALUE = @"(NULL)";

@interface MFLTextTableCellView()

@end

@implementation MFLTextTableCellView

- (void)setText:(NSString *)text {
    _text = text;

    // skip tooltips for nil or short values
    if (self.text.length > 10) {
        self.toolTip = text;
    }
    else {
        self.toolTip = nil;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    NSDictionary *style;
    switch (self.viewType) {
        case ViewTypeString:
            style = [MFLTextTableCellView styleLeftBlack];
            break;
        case ViewTypeNumber:
            style = [MFLTextTableCellView styleRightBlack];
            break;
        case ViewTypeDate:
            style = [MFLTextTableCellView styleLeftBlack];
            break;
        case ViewTypeLink:
            style = [MFLTextTableCellView styleLeftBlack];
            break;
        case ViewTypeTransformable:
            style = [MFLTextTableCellView styleLeftBlack];
            break;
    }

    CGRect textRect = CGRectMake(PADDING_X, PADDING_Y, CGRectGetWidth(self.bounds) - (PADDING_X*2), CGRectGetHeight(self.bounds) - (PADDING_Y*2));

    if (self.viewType == ViewTypeLink || self.viewType == ViewTypeTransformable) {
        textRect.size.width -= 20;
    }

    if (self.text == nil) {
        [NIL_VALUE drawInRect:textRect withAttributes:[MFLTextTableCellView styleLeftGray]];
    }
    else {
        [self.text drawInRect:textRect withAttributes:style];
    }
}

+ (NSDictionary *)styleLeftBlack {
    static NSDictionary *styleLeftBlack; // left-aligned; black
    if (styleLeftBlack == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSLeftTextAlignment];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];

        NSFont *font = [NSFont systemFontOfSize:12];
        NSColor *color = [NSColor blackColor];

        styleLeftBlack = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : style};
    }
    return styleLeftBlack;
}

+ (NSDictionary *)styleRightBlack {
    static NSDictionary *styleRightBlack; // right-aligned; black
    if (styleRightBlack == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSRightTextAlignment];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];

        NSFont *font = [NSFont systemFontOfSize:12];
        NSColor *color = [NSColor blackColor];

        styleRightBlack = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : style};
    }
    return styleRightBlack;
}

+ (NSDictionary *)styleLeftGray {
    static NSDictionary *styleLeftGray; // left-aligned; gray
    if (styleLeftGray == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSLeftTextAlignment];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];

        NSFont *font = [NSFont systemFontOfSize:12];
        NSColor *color = [NSColor grayColor];

        styleLeftGray = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : style};
    }
    return styleLeftGray;
}

@end
