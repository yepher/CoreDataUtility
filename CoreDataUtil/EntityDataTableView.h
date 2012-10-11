//
//  EntityDataTableView.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/6/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EntityDataTableViewCell.h"

@interface EntityDataTableView : NSTableView
{
    NSInteger rightClickedCol;
    NSInteger rightClickedRow;
}

- (NSInteger)getRightClickedCol;
- (NSInteger)getRightClickedRow;


@end
