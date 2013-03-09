//
//  EntityTableView.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/6/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EntityTableViewDataSource <NSObject>

- (NSSet *)tableSectionIndexes;
- (NSInteger)sectionIndexForRow:(NSInteger)row;

@end

@interface EntityTableView : NSOutlineView
{
    NSInteger rightClickedRow;
}

@property (weak) IBOutlet id<EntityTableViewDataSource> entityDataSource;

- (NSInteger)getRightClickedRow;

@end
