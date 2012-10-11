//
//  GetInfoSheetController.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 5/30/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "GetInfoSheetController.h"
#import "EntityDataTableViewCell.h"

@interface GetInfoSheetController ()

@property (strong) NSMutableArray *parentCells;
@property (strong) NSMutableDictionary *childCells;
@property (strong) NSEntityDescription *initialValues;
@property (strong) NSDictionary *entityUserInfo;

- (void)initialize;
- (void)removeColumns;
- (void)addTableColumnWithIdentifier:(NSString *)ident;
- (NSString *)convertAttributeType:(NSAttributeDescription *)prop;
- (NSString *)convertDeleteRule:(NSRelationshipDescription *)prop;
- (NSArray *)createCellChildrenCells:(NSPropertyDescription *)property;
- (void)populateOutlineView;

@end

@implementation GetInfoSheetController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if (self.initialValues != nil)
    {
        [self initialize];
    }
}

- (void)initialize
{
    [self removeColumns];
    [self addTableColumnWithIdentifier:@"Key"];
    [self addTableColumnWithIdentifier:@"Value"];
    
    [self.entityNameTextField setStringValue:[self.initialValues name]];
    
    self.entityUserInfo = [self.initialValues userInfo];
    
    [self populateOutlineView];
    [self.entityDescriptionOutlineView setDataSource:self];
    [self.entityDescriptionOutlineView reloadData];
}

- (void)removeColumns
{
    while ([[self entityUserInfoTableView] numberOfColumns] > 0)
    {
        [self.entityUserInfoTableView removeTableColumn:[self.entityUserInfoTableView tableColumns][0]];
    }
}

- (void)addTableColumnWithIdentifier:(NSString *)ident
{
    NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier:ident];
    
    [[newColumn headerCell] setTitle:NSLocalizedStringFromTable(ident, @"TableHeaders", nil)];
    [newColumn sizeToFit];
    
    [[self entityUserInfoTableView] addTableColumn:newColumn];
}

- (NSString *)convertAttributeType:(NSAttributeDescription *)prop
{
    NSString *attribType = @"(null)";
    switch ([prop attributeType])
    {
        case NSUndefinedAttributeType:
            attribType = @"NSUndefinedAttributeType";
        break;
        case NSInteger16AttributeType:
            attribType = @"NSInteger16AttributeType";
        break;
        case NSInteger32AttributeType:
            attribType = @"NSInteger32AttributeType";
        break;
        case NSInteger64AttributeType:
            attribType = @"NSInteger64AttributeType";
        break;
        case NSDecimalAttributeType:
            attribType = @"NSDecimalAttributeType";
        break;
        case NSDoubleAttributeType:
            attribType = @"NSDoubleAttributeType";
        break;
        case NSFloatAttributeType:
            attribType = @"NSFloatAttributeType";
        break;
        case NSStringAttributeType:
            attribType = @"NSStringAttributeType";
        break;
        case NSBooleanAttributeType:
            attribType = @"NSBooleanAttributeType";
        break;
        case NSDateAttributeType:
            attribType = @"NSDateAttributeType";
        break;
        case NSBinaryDataAttributeType:
            attribType = @"NSBinaryDataAttributeType";
        break;
        case NSTransformableAttributeType:
            attribType = @"NSTransformableAttributeType";
        break;
        case NSObjectIDAttributeType:
            attribType = @"NSObjectIDAttributeType";
        break;
    }
    
    return attribType;
}

- (NSString *)convertDeleteRule:(NSRelationshipDescription *)prop
{
    NSString *deleteRule = @"(null)";
    switch ([prop deleteRule])
    {
        case NSNoActionDeleteRule:
            deleteRule = @"NSNoActionDeleteRule";
        break;
        case NSNullifyDeleteRule:
            deleteRule = @"NSNullifyDeleteRule";
        break;
        case NSCascadeDeleteRule:
            deleteRule = @"NSCascadeDeleteRule";
        break;
        case NSDenyDeleteRule:
            deleteRule = @"NSDenyDeleteRule";
        break;
    }
    
    return deleteRule;
}

- (NSMutableArray *)createCellChildrenCells:(NSPropertyDescription *)property
{
    NSMutableArray *desc = [[NSMutableArray alloc] init];
    
    NSString *validationPredicates = [[[property validationPredicates] componentsJoinedByString:@", "] isEqualToString:@""] ? @"(empty)" : [[property validationPredicates] componentsJoinedByString:@", "];
    NSString *validationWarnings = [[[property validationWarnings] componentsJoinedByString:@", "] isEqualToString:@""] ? @"(empty)" : [[property validationWarnings] componentsJoinedByString:@", "];
    if ([property isKindOfClass:[NSAttributeDescription class]])
    {
        NSAttributeDescription *prop = (NSAttributeDescription *)property;
        
        EntityDataTableViewCell *cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"isOptional = %@", [property isOptional] == YES ? @"YES" : @"NO"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"isTransient = %@", [property isTransient] == YES ? @"YES" : @"NO"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"entity = %@", [[property entity] name]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"renamingIdentifier = %@", [property renamingIdentifier]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"validation predicates = %@", validationPredicates]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"warnings = %@", validationWarnings]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"versionHashModifier = %@", [property versionHashModifier] ? [property versionHashModifier] : @"(null)"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"attributeType = %@", [self convertAttributeType:prop]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"attributeClassName = %@", [prop attributeValueClassName]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"defaultValue = %@", [prop defaultValue]]];
        [desc addObject:cell];
    }
    else if ([property isKindOfClass:[NSRelationshipDescription class]])
    {
        NSRelationshipDescription *prop = (NSRelationshipDescription *)property;
        
        EntityDataTableViewCell *cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"isOptional = %@", [property isOptional] == YES ? @"YES" : @"NO"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"isTransient = %@", [property isTransient] == YES ? @"YES" : @"NO"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"entity = %@", [[property entity] name]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"renamingIdentifier = %@", [property renamingIdentifier]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"validation predicates = %@", validationPredicates]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"warnings = %@", validationWarnings]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"versionHashModifier = %@", [property versionHashModifier] ? [property versionHashModifier] : @"(null)"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"destinationEntity = %@", [[prop destinationEntity] name]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"inverseRelationship = %@", [[prop inverseRelationship] name]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"minCount = %ld", [prop minCount]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"maxCount = %ld", [prop maxCount]]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"idOrdered = %@", [prop isOrdered] == YES ? @"YES" : @"NO"]];
        [desc addObject:cell];
        cell = [[EntityDataTableViewCell alloc] init];
        [cell setCellType:CellTypeNone];
        [cell setCellText:[NSString stringWithFormat:@"deleteRule = %@", [self convertDeleteRule:prop]]];
        [desc addObject:cell];
    }
    
    return desc;
}

- (void)populateOutlineView
{
    self.parentCells = [[NSMutableArray alloc] init];
    self.childCells = [[NSMutableDictionary alloc] init];
    
    for (NSPropertyDescription *property in self.initialValues)
    {
        EntityDataTableViewCell *parent = [[EntityDataTableViewCell alloc] init];
        NSString *key = [property name];
        [parent setCellText:key];
        if ([property isKindOfClass:[NSAttributeDescription class]])
        {
            NSAttributeDescription *prop = (NSAttributeDescription *)property;
            if ([[prop attributeValueClassName] isEqualToString:@"NSData"])
            {
                [parent setCellType:OutlineCellTypeBinary];
            }
            else if ([[prop attributeValueClassName] isEqualToString:@"NSDate"])
            {
                [parent setCellType:OutlineCellTypeDate];
            }
            else if ([[prop attributeValueClassName] isEqualToString:@"NSNumber"] || [[prop attributeValueClassName] isEqualToString:@"NSDecimal"])
            {
                if ([prop attributeType] == NSBooleanAttributeType)
                {
                    [parent setCellType:OutlineCellTypeBoolean];
                }
                else
                {
                    [parent setCellType:OutlineCellTypeNumber];
                }
            }
            else if ([[prop attributeValueClassName] isEqualToString:@"NSString"])
            {
                [parent setCellType:OutlineCellTypeString];
            }
            else // managed object
            {
                key = [NSString stringWithFormat:@"%@    %@", [property name], [prop attributeValueClassName]];
                [parent setCellText:key];
                [parent setCellType:OutlineCellTypeObject];
            }
        }
        else if ([property isKindOfClass:[NSRelationshipDescription class]])
        {
            NSRelationshipDescription *prop = (NSRelationshipDescription *)property;
            if ([[[prop destinationEntity] name] isEqualToString:@"NSData"])
            {
                [parent setCellType:OutlineCellTypeBinary];
            }
            else if ([[[prop destinationEntity] name] isEqualToString:@"NSDate"])
            {
                [parent setCellType:OutlineCellTypeDate];
            }
            else if ([[[prop destinationEntity] name] isEqualToString:@"NSNumber"] || [[[prop destinationEntity] name] isEqualToString:@"NSDecimal"])
            {
                [parent setCellType:OutlineCellTypeNumber];
            }
            else if ([[[prop destinationEntity] name] isEqualToString:@"NSString"])
            {
                [parent setCellType:OutlineCellTypeString];
            }
            else // managed object
            {
                key = [NSString stringWithFormat:@"%@    %@", [property name], [[prop destinationEntity] name]];
                [parent setCellText:key];
                [parent setCellType:OutlineCellTypeObject];
            }
        }
        [self.parentCells addObject:parent];
        
        (self.childCells)[key] = [self createCellChildrenCells:property];
    }
}

- (IBAction)closeAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

- (void)show:(NSWindow *)sender :(NSEntityDescription *) initial
{
    self.initialValues = initial;
    [self initialize];
    
    [NSApp beginSheet:self.window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
	// sheet is up here...
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}

#pragma mark
#pragma NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil)
    {
        return [self.parentCells count];
    }
    else
    {
        EntityDataTableViewCell *parent = (EntityDataTableViewCell *)item;
        return [(self.childCells)[parent.cellText] count];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    EntityDataTableViewCell *cell = (EntityDataTableViewCell *)item;
    if ([cell.cellText rangeOfString:@"="].length <= 0)
    {
        return YES;
    }
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    EntityDataTableViewCell *cell = (EntityDataTableViewCell *)item;
    if (cell == nil)
    {
        return (self.parentCells)[index];
    }
    else
    {
        return (self.childCells)[cell.cellText][index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return item;
}

#pragma mark
#pragma NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}

#pragma mark
#pragma NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.entityUserInfo count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *key = [self.entityUserInfo allKeys][rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString:@"Key"])
    {
        return key;
    }
    else
    {
        return (self.entityUserInfo)[key];
    }
}

#pragma mark
#pragma NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

@end
