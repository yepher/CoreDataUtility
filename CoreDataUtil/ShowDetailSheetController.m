//
//  ShowDetailSheetController.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/7/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "ShowDetailSheetController.h"
#import "MFLConstants.h"

//#define DATE_STYLE_KEY_NAME @"dateStyleKey"

@interface ShowDetailSheetController ()

@end

@implementation ShowDetailSheetController

@synthesize detailInfo;
@synthesize detailTableView;
@synthesize lastColumn;

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
    sortType = Unsorted;
    
    if (self.detailInfo != nil)
    {
        [self reloadDetailTableView];
    }
}

- (void)buttonClicked:(id)sender
{
    NSInteger col = [self.detailTableView columnAtPoint:[sender frame].origin];
    NSInteger row = [self.detailTableView rowAtPoint:[sender frame].origin];
    
    NSArray *dataRow;
    if (sortType == Descending)
    {
        dataRow = [self.detailInfo objectAtIndex:[self.detailTableView numberOfRows] - row - 1];
    }
    else
    {
        dataRow = [self.detailInfo objectAtIndex:row];
    }
    NSTableColumn *column = [[self.detailTableView tableColumns] objectAtIndex:col];
    
    id valueObj = [dataRow valueForKey:[column identifier]];
    if (valueObj != nil)
    {
        if ([valueObj isKindOfClass:[NSManagedObject class]])
        {
            NSManagedObject *managedObject = (NSManagedObject *)valueObj;
            self.detailInfo = [[NSArray alloc] initWithObjects:managedObject, nil];
            [self reloadDetailTableView];
        }
        else if ([valueObj isKindOfClass:[NSArray class]])
        {
            self.detailInfo = (NSArray *)valueObj;
            [self reloadDetailTableView];
        }
        else if ([valueObj isKindOfClass:[NSSet class]])
        {
            NSSet *set = (NSSet *)valueObj;
            self.detailInfo = [set sortedArrayUsingDescriptors:nil];
            [self reloadDetailTableView];
        }
    }
}

- (IBAction)closeButtonAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

- (void)show:(MFLMainWindowController *)sender:(NSArray *) initial
{
    self.detailInfo = initial;
    [self reloadDetailTableView];
    
    [NSApp beginSheet:self.window modalForWindow:[sender window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
	// sheet is up here...
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}

#pragma mark
#pragma NSTableViewDataSource

- (void)reloadDetailTableView
{
    sortType = Unsorted;
    
    [self removeColumns];
    
    NSArray* columnNames = [self entityColumnNames];
    for (NSString* name in columnNames)
    {
        [self addTableColumnWithIdentifier:name];
    }   
    [self.detailTableView reloadData];
}

- (void)removeColumns
{
    while ([[self detailTableView] numberOfColumns] > 0)
    {
        [self.detailTableView removeTableColumn:[[self.detailTableView tableColumns] objectAtIndex:0]];
    }
}

- (NSArray*)entityColumnNames
{
    NSMutableArray* columnNames = [[NSMutableArray alloc] init];
    if (self.detailInfo != nil && [self.detailInfo count] > 0)
    {
        NSEntityDescription *entityDescription = [[self.detailInfo objectAtIndex:0] entity];
        for (NSPropertyDescription *property in entityDescription)
        {
            [columnNames addObject:[property name]];
        }
    }
    
    return columnNames;
}

- (void)addTableColumnWithIdentifier:(NSString *)ident
{
    NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier:ident];
    [[newColumn headerCell] setTitle:NSLocalizedStringFromTable(ident, @"TableHeaders", nil)];
    
    CGFloat defaultColWidth = [newColumn width];
    [newColumn sizeToFit];
    if ([newColumn width] < defaultColWidth)
    {
        [newColumn setMinWidth:defaultColWidth];
    }
    
    [[self detailTableView] addTableColumn:newColumn];
    
    // TODO: we should set the cells up with proper types when we allow users to edit data
    //    if (...)
    //    {
    //        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    //        [numberFormatter setFormat:@"$#,##0.00"];
    //        [[newColumn dataCell] setFormatter:numberFormatter];
    //        [[newColumn dataCell] setAlignment:NSRightTextAlignment];
    //    }
    
    NSMutableDictionary *bindingOptions=[NSMutableDictionary dictionary];
    [bindingOptions setObject:[NSNumber numberWithBool:YES] forKey:NSValidatesImmediatelyBindingOption];
    
    // You can probably do some sort of dynamic binding here:
    //NSString *keyPath = [NSString stringWithFormat:@"arrangedObjects.%@", ident];
    //[newColumn bind: @"value" toObject: productArrayController withKeyPath:keyPath options:bindingOptions];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.detailInfo count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return nil;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableColumn)
    {
        EntityDataTableViewCell *cell = [[EntityDataTableViewCell alloc] init];
        
        NSArray* dataRow;
        if (sortType == Descending)
        {
            dataRow = [self.detailInfo objectAtIndex:[tableView numberOfRows] - row - 1];
        }
        else
        {
            dataRow = [self.detailInfo objectAtIndex:row];
        }
        id valueObj = [dataRow valueForKey:[tableColumn identifier]];
        
        NSString *cellText = [MFLCoreDataIntrospection getDisplayValueForObject:valueObj: [self getNSDateFormatterStyle]];
        if ([cellText isKindOfClass:[NSNumber class]])
        {
            NSNumber *num = (NSNumber *)cellText;
            cellText = [num stringValue];
        }
        [cell setCellText:cellText];
        
        if ([valueObj isKindOfClass:[NSManagedObject class]])
        {
            [cell setCellType:CellTypeManagedObject];
        }
        else if ([valueObj isKindOfClass:[NSSet class]] || [valueObj isKindOfClass:[NSArray class]])
        {
            [cell setCellType:CellTypeCollection];
        }
        else
        {
            [cell setCellType:CellTypeNone];
        }
        
        return cell;
    }
    
    return nil;
}


- (NSDateFormatterStyle)getNSDateFormatterStyle
{
    NSDateFormatterStyle dateStyle = [[NSUserDefaults standardUserDefaults] integerForKey:DATE_STYLE_KEY_NAME]; 
    if (dateStyle == 0) {
        dateStyle = NSDateFormatterShortStyle;
    } 
       
    return dateStyle;
}

#pragma mark
#pragma NSTableViewDelegate

- (void)sortEntityData:(NSString *)columnId
{
    NSDateFormatterStyle dateStyle = [self getNSDateFormatterStyle];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:dateStyle];
    [formatter setTimeStyle:dateStyle];
    
    // Put values for selected column into a dictionary with their current row number as the key
    NSMutableDictionary *columnObjs = [[NSMutableDictionary alloc] init];
    NSInteger rowNum = 0;
    for (NSArray *row in self.detailInfo)
    {
        id valueObj = [MFLCoreDataIntrospection getDisplayValueForObject:[row valueForKey:columnId]: [self getNSDateFormatterStyle]];
        if ([valueObj isKindOfClass:[NSString class]] && [formatter dateFromString:valueObj])
        {
            valueObj = [formatter dateFromString:valueObj];
        }
        
        [columnObjs setObject:valueObj forKey:[NSString stringWithFormat:@"%d", rowNum]];
        rowNum++;
    }
    
    // sort!
    NSArray *sortedColumns = [columnObjs keysSortedByValueUsingSelector:@selector(compare:)];
    
    // Move the sorted values back into an array
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSString *oldRowNum in sortedColumns)
    {
        [temp addObject:[self.detailInfo objectAtIndex:[oldRowNum integerValue]]];
    }
    self.detailInfo = temp;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSString *arrowImageName;
    if ([[self.lastColumn identifier] isEqualToString:[tableColumn identifier]])
    {
        if (sortType == Descending)
        {
            sortType = Ascending;
            arrowImageName = @"NSAscendingSortIndicator";
        }
        else
        {
            sortType = Descending;
            arrowImageName = @"NSDescendingSortIndicator";
        }
    }
    else
    {
        sortType = Ascending;
        arrowImageName = @"NSAscendingSortIndicator";
        
        [self.detailTableView setIndicatorImage:nil inTableColumn:self.lastColumn];
        self.lastColumn = tableColumn;
        
        [self sortEntityData:[tableColumn identifier]];
    }
    
    [self.detailTableView setIndicatorImage:[NSImage imageNamed:arrowImageName] inTableColumn:tableColumn];
    [self.detailTableView reloadData];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

@end
