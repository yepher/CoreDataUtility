//
//  EntityDataTableViewCell.h
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/19/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
    CellTypeManagedObject,
    CellTypeCollection,
    CellTypeNone,
    OutlineCellTypeBinary,
    OutlineCellTypeBoolean,
    OutlineCellTypeDate,
    OutlineCellTypeNumber,
    OutlineCellTypeObject,
    OutlineCellTypeString
}CellType;

@interface EntityDataTableViewCell : NSTextFieldCell
{
    CellType cellType;
}

@property (strong) NSString *cellText;

- (CellType)getCellType;
- (void)setCellType:(CellType)type;

@end
