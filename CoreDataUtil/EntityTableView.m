//
//  EntityTableView.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/6/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "EntityTableView.h"

@implementation EntityTableView

- (NSInteger)getRightClickedRow
{
    return rightClickedRow;
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    rightClickedRow = [self rowAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Entity Info" action:@selector(getInfoAction) keyEquivalent:@"I"]];
    
    return menu;
}

@end
