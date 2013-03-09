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
    
	NSMenu *menu;
	if (![[self.entityDataSource tableSectionIndexes] containsObject:@(rightClickedRow)])
	{
		menu = [[NSMenu alloc] init];
		if ([self.entityDataSource sectionIndexForRow:rightClickedRow] == 0) {
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Entity Info" action:@selector(getInfoAction) keyEquivalent:@"I"]];
		} else if ([self.entityDataSource sectionIndexForRow:rightClickedRow] == 1){
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Fetch Request Info" action:@selector(getInfoAction) keyEquivalent:@"I"]];
		}
		

	}

    return menu;
}


@end
