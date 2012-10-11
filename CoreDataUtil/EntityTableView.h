//
//  EntityTableView.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/6/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EntityTableView : NSTableView
{
    NSInteger rightClickedRow;
}

- (NSInteger)getRightClickedRow;

@end
