//
//  MFLMainWindowController.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLMainWindowController.h"
#import "MFLConstants.h"
#import "MFLCoreDataIntrospection.h"
#import "EntityTableView.h"
#import "EntityDataTableView.h"
#import "MFLTextTableCellView.h"
#import "MFLEntityTableCellView.h"
#import "MFLButtonTableViewCell.h"
#import "MFLCellBuilder.h"
#import "OpenFileSheetController.h"
#import "GetInfoSheetController.h"
#import "MFLInAppPurchaseHelperSubclass.h"
#import "InAppPurchaseWindowController.h"

#define kEntitiesRootNode @"rootNode"

@interface OutlineViewNode : NSObject
@property (strong) OutlineViewNode *parent;
@property (strong) NSString *title;
@property (assign) int index;
@property (assign) int badgeValue;
@property (strong) NSMutableArray *childs;
- (void) addChild:(OutlineViewNode *)node;
- (void) removeChild:(OutlineViewNode *)node;
- (BOOL) hasChild:(OutlineViewNode *)node;
@end

@implementation OutlineViewNode
- (id) init {
    self = [super init];
    self.childs = [NSMutableArray new];
    return self;
}
- (void) addChild:(OutlineViewNode *)node {
    node.parent = self;
    [self.childs addObject:node];
}
- (void) removeChild:(OutlineViewNode *)node {
    node.parent = nil;
    [self.childs removeObject:node];
}
- (BOOL) hasChild:(OutlineViewNode *)node {
    return [self.childs indexOfObject:node] != NSNotFound;
}
@end


@interface MFLMainWindowController ()

@property (strong) MFLCoreDataIntrospection *coreDataIntrospection;
@property (nonatomic) NSDateFormatterStyle dateStyle;
@property (nonatomic) NSInteger sortType;
@property (weak) NSTableColumn *lastColumn;
@property (strong) NSArray* baseRowTemplates;
@property (weak) IBOutlet NSPredicateEditor *predicateEditor;
@property (strong) OutlineViewNode *rootNode;

- (void) loadUserDefinedDateFormat;
- (BOOL)canEnableBackHistoryControl;
- (BOOL)canEnableForwardHistoryControl;
- (void)enableDisableHistorySegmentedControls;
- (void)reloadEntityDataTable:(NSString *)name :(NSPredicate *)predicate;
- (NSEntityDescription *)getEntityForPredicateEditor;

@end

@implementation MFLMainWindowController


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
        self.sortType = Unsorted;
    }
    
    return self;
}


- (void) loadUserDefinedDateFormat {
    NSInteger dateStyleDefault = [[NSUserDefaults standardUserDefaults] integerForKey:DATE_STYLE_KEY_NAME]; 
    if (dateStyleDefault == 0) {
        self.dateStyle = NSDateFormatterShortStyle;
        [[NSUserDefaults standardUserDefaults] setInteger:self.dateStyle forKey:DATE_STYLE_KEY_NAME];
    } else {
        self.dateStyle = dateStyleDefault;
    }
    
    // Initialize Date Format
    if (self.userSelecteddateFormat != nil) {
        switch (self.dateStyle) {
            case NSDateFormatterShortStyle:
                [self.userSelecteddateFormat setSelectedSegment:0];
                break;
            case NSDateFormatterMediumStyle:
                [self.userSelecteddateFormat setSelectedSegment:1];
                break;
            case NSDateFormatterLongStyle:
                [self.userSelecteddateFormat setSelectedSegment:2];
                break;
            case NSDateFormatterFullStyle:
                [self.userSelecteddateFormat setSelectedSegment:3];
                break;
            default:
                [self.userSelecteddateFormat setSelectedSegment:0];
                self.dateStyle = NSDateFormatterShortStyle;
                break;
        }
    }
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.dataSourceList setDataSource:self];
    [self.dataSourceList setDelegate:self];
    
    [self.entityContentTable setDataSource:self];
    [self.entityContentTable setDelegate:self];
    
    [self.historySegmentedControl setEnabled:NO forSegment:0];
    [self.historySegmentedControl setEnabled:NO forSegment:1];
    
    [self loadUserDefinedDateFormat];
}

#pragma mark -
#pragma TableView Columns helpers

- (void)addTableColumnWithIdentifier:(NSString *)ident
{
    //NSLog(@"Adding Column: %@", ident);
    NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier:ident];
    [[newColumn headerCell] setTitle:NSLocalizedStringFromTable(ident, @"TableHeaders", nil)];
    
    NSFont *headerFont = [NSFont boldSystemFontOfSize:13];
    [[newColumn headerCell] setFont: headerFont];
    [[newColumn headerCell] setTextColor:[NSColor darkGrayColor]];
    [[newColumn headerCell] setAlignment:NSCenterTextAlignment];
    
    
    CGFloat defaultColWidth = [newColumn width];
    [newColumn sizeToFit];
    if ([newColumn width] < defaultColWidth)
    {
        [newColumn setMinWidth:defaultColWidth];
    }
    
    [[self entityContentTable] addTableColumn:newColumn];
    
    // TODO: we should set the cells up with proper types when we allow users to edit data
    //    if (...)
    //    {
    //        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    //        [numberFormatter setFormat:@"$#,##0.00"];
    //        [[newColumn dataCell] setFormatter:numberFormatter];
    //        [[newColumn dataCell] setAlignment:NSRightTextAlignment];
    //    }
    
    NSMutableDictionary *bindingOptions=[NSMutableDictionary dictionary];
    bindingOptions[NSValidatesImmediatelyBindingOption] = @YES;
    
    // You can probably do some sort of dynamic binding here:
    //NSString *keyPath = [NSString stringWithFormat:@"arrangedObjects.%@", ident];
    //[newColumn bind: @"value" toObject: productArrayController withKeyPath:keyPath options:bindingOptions];
}


- (void) removeColumns
{
    //NSLog(@"==== removeColumns");
    while ([[self entityContentTable] numberOfColumns] > 0)
    {
        [self.entityContentTable removeTableColumn:[self.entityContentTable tableColumns][0]];
    }
    //NSLog(@"There are now %ld columns", [[self entityContentTable] numberOfColumns]);
}

- (BOOL)canEnableBackHistoryControl
{
    if (self.coreDataIntrospection.coreDataHistory != nil && [self.coreDataIntrospection.coreDataHistory count] > 1)
    {
        if ([self.coreDataIntrospection getCurrentHistoryIndex] < [self.coreDataIntrospection.coreDataHistory count]-1)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)canEnableForwardHistoryControl
{
    if (self.coreDataIntrospection.coreDataHistory != nil && [self.coreDataIntrospection.coreDataHistory count] > 1)
    {
        if ([self.coreDataIntrospection getCurrentHistoryIndex] > 0)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)enableDisableHistorySegmentedControls
{
    if ([self canEnableBackHistoryControl])
    {
        [self.historySegmentedControl setEnabled:YES forSegment:0];
    }
    else
    {
        [self.historySegmentedControl setEnabled:NO forSegment:0];
    }
    
    if ([self canEnableForwardHistoryControl])
    {
        [self.historySegmentedControl setEnabled:YES forSegment:1];
    }
    else
    {
        [self.historySegmentedControl setEnabled:NO forSegment:1];
    }
}

#pragma mark
#pragma mark NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //NSLog(@"- (void)tableViewSelectionDidChange:[%@]", aNotification);
    
    if ([self.dataSourceList isEqualTo:[aNotification object]])
    {
        if ([self.dataSourceList selectedRow] >= 0)
        {
            [self removeColumns];
            [self.coreDataIntrospection clearEntityData];
            [self.entityContentTable reloadData];
            
            self.sortType = Unsorted;
            
            NSInteger selected = [self.dataSourceList selectedRow] - 1;
            NSLog(@"Selected idx=%ld", selected);
            if (selected >= 0)
            {
                [self.coreDataIntrospection loadEntityDataAtIndex:selected];
                NSArray* columnNames = [self.coreDataIntrospection entityFieldNames:[self.coreDataIntrospection entityAtIndex:selected]];
                for (NSString* name in columnNames)
                {
                    [self addTableColumnWithIdentifier:name];
                }
                
                [self.coreDataIntrospection loadEntityDataAtIndex:selected];
            }
            [self.entityContentTable reloadData];
            
            [self.coreDataIntrospection updateCoreDataHistory:[self.coreDataIntrospection entityAtIndex:selected] :nil];
            [self enableDisableHistorySegmentedControls];
        }
    }
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    NSString *arrowImageName;
    if ([[self.lastColumn identifier] isEqualToString:[tableColumn identifier]])
    {
        if (self.sortType == Descending)
        {
            self.sortType = Ascending;
            arrowImageName = @"NSAscendingSortIndicator";
        }
        else
        {
            self.sortType = Descending;
            arrowImageName = @"NSDescendingSortIndicator";
        }
    }
    else
    {
        self.sortType = Ascending;
        arrowImageName = @"NSAscendingSortIndicator";
        
        [self.entityContentTable setIndicatorImage:nil inTableColumn:self.lastColumn];
        self.lastColumn = tableColumn;
        
        [self.coreDataIntrospection setDateStyle:self.dateStyle];
        [self.coreDataIntrospection sortEntityData:[tableColumn identifier]];
    }
    
    [self.entityContentTable setIndicatorImage:[NSImage imageNamed:arrowImageName] inTableColumn:tableColumn];
    [self.entityContentTable reloadData];
}



#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (self.coreDataIntrospection == nil) {
        return 0;
    }
    
    if (aTableView == [self dataSourceList])
    {
        //NSLog(@"entityTable  numberOfRowsInTableView=[%lu]", [self.coreDataIntrospection entityCount]);
        return [self.coreDataIntrospection entityCount];
        
    }  else if (aTableView == [self entityContentTable])
    {
        //NSLog(@"entityContentTable  numberOfRowsInTableView=[%lu]", [self.coreDataIntrospection entityDataCount]);
        return [self.coreDataIntrospection entityDataCount];
    } else {
        NSLog(@"Error: unknown table view selected. [%@]", aTableView);
    }
    return 0;
}

- (id)getValueObjFromDataRows:(NSTableView *)tableView :(NSInteger)row :(NSTableColumn *)tableColumn
{
    NSArray* dataRow;
    NSInteger normalizedRow = [self sortOrderedRow:tableView row:row];
    
    id valueObj = nil;
    @try
    {
        dataRow = [self.coreDataIntrospection getDataAtRow:normalizedRow];
        
        valueObj = [dataRow valueForKey:[tableColumn identifier]];
    }
    @catch (NSException *exception)
    {
        // Not sure what is going on here. This happens sometimes. We need to sort this one out...
        NSLog(@"Row=%ld, normalizedRow=%ld, numRows=%ld, entityCount=%ld", row, normalizedRow, [self.entityContentTable numberOfRows], [self.coreDataIntrospection entityDataCount]);
        NSLog(@"Row[%ld]: Caught Exception: %@ [%@], %@",row, exception, tableColumn, dataRow);
        valueObj = nil;
    }
    
    return valueObj;
}

- (NSInteger) sortOrderedRow:(NSTableView *)tableView row:(NSInteger) row {
    NSInteger normalizedRow = row;
    if (self.sortType == Descending)
    {
        normalizedRow = [tableView numberOfRows] - row - 1;
    }
    
    return normalizedRow;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{    
    if (tableView == [self dataSourceList])
    {
        MFLEntityTableCellView* entityCell = [tableView makeViewWithIdentifier:MFL_ENTITY_CELL owner:self];
        NSString* lblTxt = [self.coreDataIntrospection entityAtIndex:row];
        
        [[entityCell label] setStringValue:lblTxt];
        //[entityCell setDataCount:[NSString stringWithFormat:@"%ld", [self.coreDataIntrospection entityDataCountAtIndex:row]]];
        [[entityCell countButton] setTitle: [NSString stringWithFormat:@"%ld", [self.coreDataIntrospection entityDataCountAtIndex:row]]];
        //[[entityCell countButton] sizeToFit];
        [[entityCell countButton] setEnabled:NO];
        
        return entityCell;
    }
    
    if (tableView == [self entityContentTable])
    {
        id valueObj = [self getValueObjFromDataRows:tableView :row :tableColumn];
        
        if (valueObj == nil)
        {
            MFLTextTableCellView* textCell = [MFLCellBuilder nullCell:tableView owner:self];
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSString class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%@", valueObj];
            MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSURL class]])
        {
            NSURL* url = (NSURL*) valueObj;
            NSString* cellText = [NSString stringWithFormat:@"%@", [url absoluteString]];
            MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSDate class]])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:self.dateStyle];
            [dateFormatter setTimeStyle:self.dateStyle];
            NSString *cellText = [dateFormatter stringFromDate:valueObj];
            MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
            
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSData class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%ld", [valueObj length]];
            MFLTextTableCellView* textCell = [MFLCellBuilder numberCellWithString:tableView textToSet:cellText owner: self];
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSNumber class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%@", valueObj];
            MFLTextTableCellView* textCell = [MFLCellBuilder numberCellWithString:tableView textToSet:cellText owner:self];
            return textCell;
        }
        
        // Button Cells
        else if ([valueObj isKindOfClass:[NSManagedObject class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%@", [[valueObj entity] name]];
            MFLButtonTableViewCell* buttonCell = [MFLCellBuilder objectCellWithString:tableView textToSet:cellText owner:self];
            return buttonCell;
        }
        else if ([valueObj isKindOfClass:[NSSet class]])
        {
            if ([valueObj count] > 0)
            {
                NSManagedObject* object = [valueObj anyObject];
                NSString *cellText = [NSString stringWithFormat:@"%@[%ld]", [[object entity] name], [valueObj count]];
                
                MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                [[buttonCell infoField] setAlignment:NSRightTextAlignment];
                [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                [[buttonCell infoField] setStringValue: cellText];
                return buttonCell;
            }
            else // Empty NSSet
            {
                MFLTextTableCellView* textCell = [MFLCellBuilder nullCell:tableView owner:self];
                return textCell;
            }            
        }
        else if ([valueObj isKindOfClass:[NSArray class]])
        {
            if ([valueObj count] > 0)
            {
                NSManagedObject* object = [valueObj firstItem];
                NSString *cellText = [NSString stringWithFormat:@"%@[%ld]", [[object entity] name], [valueObj count]];
                
                MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                [[buttonCell infoField] setAlignment:NSRightTextAlignment];
                [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                [[buttonCell infoField] setStringValue: cellText];
                return buttonCell;
            }
            else // Empty NSArray
            {
                MFLTextTableCellView* textCell = [MFLCellBuilder nullCell:tableView owner:self];
                return textCell;
            }
        }
        
        // Unhandled types of content
        else 
        {
            NSLog(@"is Other");
            
            NSString* cellText = [NSString stringWithFormat:@"??? %@ ???", [valueObj class]];
            MFLTextTableCellView* textCell = [MFLCellBuilder numberCellWithString:tableView textToSet:cellText owner:self];
            [[textCell infoField] setTextColor:[NSColor redColor]];
            
            return textCell;
        } 
    }
    
    return nil;
}

#pragma mark - Outline view

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return self.rootNode.childs.count;
    }
    
    OutlineViewNode *node = item;
    return node.childs.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return self.rootNode.childs[index];
    }
    
    OutlineViewNode *node = item;
    return node.childs[index];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *cell = nil;
    OutlineViewNode *node = item;
    if ([self.rootNode hasChild:item]) {
        cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        cell.textField.stringValue = [node.title uppercaseString];
    }
    else {
        cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        cell.textField.stringValue = node.title;
        NSButton *button = [cell viewWithTag:1];
        button.title = [NSString stringWithFormat:@"%d", node.badgeValue];
    }
    
    return cell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [outlineView parentForItem:item] == nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    OutlineViewNode *node = item;
    return node.childs.count > 0;
}
- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    OutlineViewNode *node = item;
    return node.childs.count > 0;
}
- (BOOL) outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    OutlineViewNode *node = item;
    return node.childs.count <= 0;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self tableViewSelectionDidChange:notification];
}


#pragma mark - 
#pragma mark Helpers

- (BOOL) openFiles:(NSURL*) momFile persistenceFile:(NSURL*) persistenceFile persistenceType:(NSInteger) persistenceType
{
    [self.window makeKeyAndOrderFront:self];
    
    [self openCoreDataIntrospectionWithUrls:momFile persistFileUrl:persistenceFile persistFormat:persistenceType];
    
    self.rootNode = [OutlineViewNode new];
    self.rootNode.index = 0;
    self.rootNode.title = @"";
    
    OutlineViewNode *entitiesNode = [OutlineViewNode new];
    entitiesNode.title = @"entities";
    entitiesNode.index = 0;
    [self.rootNode addChild:entitiesNode];
    
    NSUInteger entityCount = self.coreDataIntrospection.entityCount;
    for(NSUInteger i=0; i<entityCount; i++) {
        OutlineViewNode *node = [OutlineViewNode new];
        node.title = [self.coreDataIntrospection entityAtIndex:i];
        node.index = i;
        node.badgeValue = [self.coreDataIntrospection entityDataCountAtIndex:i];
        [entitiesNode addChild:node];
    }
    
    [self.dataSourceList reloadData];
    if (self.rootNode.childs.count > 0) {
        [self.dataSourceList expandItem:self.rootNode.childs[0]];
    }
    [self.entityContentTable reloadData];
    [self enableDisableHistorySegmentedControls];
    
    return YES;
}

- (void) openCoreDataIntrospectionWithUrls: (NSURL*) momFileUrl persistFileUrl:(NSURL*) persistFileUrl persistFormat:(NSInteger) persistFormat {
    [self setCoreDataIntrospection:[[MFLCoreDataIntrospection alloc] init]];
    [self.coreDataIntrospection setDateStyle:self.dateStyle];
    [self.coreDataIntrospection setDelegate:self];
    
    [self.coreDataIntrospection setMomFileUrl:momFileUrl];
    [self.coreDataIntrospection setDbFileUrl: persistFileUrl];
    
    NSString* storeType;
    switch (persistFormat) {
        case MFL_SQLiteStoreType:
            storeType = NSSQLiteStoreType;
            break;
        case MFL_XMLStoreType:
            storeType = NSXMLStoreType;
            break;
        case MFL_BinaryStoreType:
            storeType = NSBinaryStoreType;
            break;
        case MFL_InMemoryStoreType:
            // This is not a support storage format.
            storeType = NSInMemoryStoreType;
            break;
        default:
            storeType = NSSQLiteStoreType;
            break;
    }
    
    [self.coreDataIntrospection setStoreType:storeType];
    [self.coreDataIntrospection loadObjectModel];
}


- (NSEntityDescription*) selectedEntity { 
    NSInteger selected = [[self dataSourceList] selectedRow] - 1;
    if (selected < 0) {
        NSBeep();
        return nil;
    }
    
    NSEntityDescription* entityDescription = [self.coreDataIntrospection entityDescription:selected];
    return entityDescription;
}

- (NSURL*) momFileUrl {
    return [self.coreDataIntrospection momFileUrl];
    
}


- (NSURL*) persistenceFileUrl {
    return [self.coreDataIntrospection dbFileUrl];
}


- (NSInteger) persistenceFileFormat {
    
    //NSLog(@"[%@]=[%@]",NSSQLiteStoreType, [self.coreDataIntrospection storeType]);
    
    if ([NSSQLiteStoreType isEqualToString:[self.coreDataIntrospection storeType]]) {
        return MFL_SQLiteStoreType;
    } else if ([ NSXMLStoreType isEqualToString:[self.coreDataIntrospection storeType]]) {
        return MFL_XMLStoreType;
    } else if ([ NSBinaryStoreType isEqualToString:[self.coreDataIntrospection storeType]]) {
        return MFL_BinaryStoreType;
    } else if ([ NSInMemoryStoreType isEqualToString:[self.coreDataIntrospection storeType]]) {
        return MFL_InMemoryStoreType;
    } 

    // default
    return MFL_SQLiteStoreType;
}

#pragma mark -
#pragma mark MFLCoreDataIntrospectionDelegate

- (void) onLoadObjectModelSuccess {

}


- (void) onLoadObjectModelFailedWithError:(NSError*) error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Fatal error while opening Object Model!"];
    [alert setInformativeText:[error localizedDescription]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:nil];
}


- (void) onLoadPersistenceSuccess {
    
}


- (void) onLoadPersistenceFailedWithError:(NSError*) error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Fatal error while opening persistent store!"];
    [alert setInformativeText:[error localizedDescription]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:nil];
}

#pragma mark - 
#pragma mark NSMenu Actions

- (void)getInfoAction
{
    //NSLog(@"getInfoAction");
    NSInteger selected = [[self dataSourceList] getRightClickedRow] - 1;
    NSEntityDescription* entityDescription = [self.coreDataIntrospection entityDescription:selected];
    
    GetInfoSheetController* infoSheetController = [[GetInfoSheetController alloc] initWithWindowNibName:@"GetInfoSheetController"];
    [infoSheetController show:self.window :entityDescription];
}

#pragma mark -
#pragma mark IBActions

- (void)reloadEntityDataTable:(NSString *)name :(NSPredicate *)predicate
{
    [self removeColumns];
    [self.coreDataIntrospection clearEntityData];
    [self.entityContentTable reloadData];
    
    self.sortType = Unsorted;
    
    [self.coreDataIntrospection applyPredicate:name predicate:predicate];
    NSArray* columnNames = [self.coreDataIntrospection entityFieldNames:name];
    for (NSString* columnName in columnNames)
    {
        [self addTableColumnWithIdentifier:columnName];
    }
    [self.coreDataIntrospection applyPredicate:name predicate:predicate];
    
    [self.entityContentTable reloadData];
    [self.dataSourceList deselectRow:[self.dataSourceList selectedRow]];
}

- (IBAction)entityCellButtonClicked:(id)sender
{
    NSInteger row = [self.entityContentTable rowForView:sender];
    NSInteger column = [self.dataSourceList columnForView:sender];
    NSArray *columns = [self.entityContentTable tableColumns];
    
    id valueObj = [self getValueObjFromDataRows:self.entityContentTable :row :columns[column]];
    
    if (valueObj != nil)
    {
        if ([valueObj isKindOfClass:[NSManagedObject class]])
        {
            NSManagedObject *managedObject = (NSManagedObject *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", managedObject];
            [self reloadEntityDataTable:[[managedObject entity] name] :predicate];
            [self.coreDataIntrospection updateCoreDataHistory:[[managedObject entity] name] :predicate];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", array];
            [self reloadEntityDataTable:[[array[0] entity] name] :predicate];
            [self.coreDataIntrospection updateCoreDataHistory:[[array[0] entity] name] :predicate];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSSet class]])
        {
            NSSet *set = (NSSet *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", set];
            [self reloadEntityDataTable:[[[set anyObject] entity] name] :predicate];
            [self.coreDataIntrospection updateCoreDataHistory:[[[set anyObject] entity] name] :predicate];
            [self enableDisableHistorySegmentedControls];
        }
    }
}

- (IBAction) historyToolbarItemSelected:(id)sender
{
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSInteger currentIndex = [self.coreDataIntrospection getCurrentHistoryIndex];
    // go back
    if ([control selectedSegment] == 0 && [self canEnableBackHistoryControl])
    {
        [self.coreDataIntrospection setCurrentHistoryIndex:currentIndex+1];
        CoreDataHistoryObject *historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
        [self reloadEntityDataTable:historyObj.entityName :historyObj.predicate]; 
        [self enableDisableHistorySegmentedControls];
    }
    // go forward
    else if ([control selectedSegment] == 1 && [self canEnableForwardHistoryControl])
    {
        [self.coreDataIntrospection setCurrentHistoryIndex:currentIndex-1];
        CoreDataHistoryObject *historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
        [self reloadEntityDataTable:historyObj.entityName :historyObj.predicate];
        [self enableDisableHistorySegmentedControls];
    }
}

- (IBAction) refreshItemSelected:(id)sender
{
    //NSLog(@"refreshItemSelected [%@]", sender);
    if (self.coreDataIntrospection != nil)
    {
        [self.coreDataIntrospection reloadObjectModel];
        [self.dataSourceList reloadData];
        [self.entityContentTable reloadData];
        [self enableDisableHistorySegmentedControls];
    }
}

- (IBAction) showPredicateItemSelected:(id)sender {
    //NSLog(@"showPredicateItemSelected [%@]", sender);
    
}


- (IBAction) dateFormatItemSelected:(id)sender {
    //NSLog(@"dateFormatItemSelected [%@]", sender);
    
    NSSegmentedControl* control = (NSSegmentedControl*) sender;
    //NSLog(@"Selected %ld", [control selectedSegment]);
    
    switch ([control selectedSegment]) {
        case 0:
            // Short Date Format
            self.dateStyle = NSDateFormatterShortStyle;
            break;
        case 1:
            // Medium Date Format
            self.dateStyle = NSDateFormatterMediumStyle;
            break;
        case 2:
            // Long Date Format
            self.dateStyle = NSDateFormatterLongStyle;
            break;
        case 3:
            // Full Date Format
            self.dateStyle = NSDateFormatterFullStyle;
            break;
        default:
            // Unknown date style so revert to short...
            NSLog(@"Error: unknown date format selected. Going back to default value.");
            self.dateStyle = NSDateFormatterShortStyle;
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.dateStyle forKey:DATE_STYLE_KEY_NAME];
    
    if (self.entityContentTable != nil) {
        [self.entityContentTable reloadData];
    }
    
}

- (NSEntityDescription *)getEntityForPredicateEditor
{
    NSEntityDescription *entityDescription;
    if ([self.dataSourceList numberOfSelectedRows] > 0)
    {
        entityDescription = [self selectedEntity];
    }
    else
    {
        if (self.coreDataIntrospection.coreDataHistory != nil && [self.coreDataIntrospection.coreDataHistory count] > 0)
        {
            CoreDataHistoryObject *historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
            entityDescription = [self.coreDataIntrospection entityDescriptionForName:historyObj.entityName];
        }
    }
    
    return entityDescription;
}

- (IBAction)showPredicateEditor:(id)sender
{    
    // if the in-app purchase is not already purchased, prompt user to buy it
    if ([[MFLInAppPurchaseHelperSubclass sharedHelper] isFullVersion] == NO) {
        InAppPurchaseWindowController* inAppPurchaseSheetController = [[InAppPurchaseWindowController alloc] initWithWindowNibName:@"InAppPurchaseWindowController"];
        [inAppPurchaseSheetController show:self.window];
        inAppPurchaseSheetController = nil;
        if ([[MFLInAppPurchaseHelperSubclass sharedHelper] isFullVersion] == NO) {
            return;
        }
    }
    
    NSEntityDescription *entityDescription = [self getEntityForPredicateEditor];
    if (entityDescription == nil)
    {
        NSBeep();
        return;
    }
    
    NSLog(@"Entity Name: %@", [entityDescription name]);
    BOOL isFirstRun = NO;
    if (self.baseRowTemplates == nil)
    {
        self.baseRowTemplates = [self.predicateEditor rowTemplates];
        NSLog(@"Existing Templates: [%@]", self.baseRowTemplates);
        isFirstRun = YES;
    }
    
    NSMutableArray* allTemplates = [NSMutableArray arrayWithArray:self.baseRowTemplates];
    if (self.coreDataIntrospection.coreDataHistory != nil && [self.coreDataIntrospection.coreDataHistory count] > 0)
    {
        CoreDataHistoryObject *historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
        NSPredicateEditorRowTemplate *row = [[NSPredicateEditorRowTemplate alloc] init];
        [row setPredicate:historyObj.predicate];
        [allTemplates addObject:row];
    }
    
    NSArray *keyPaths = [self.coreDataIntrospection keyPathsForEntity:entityDescription];
    NSArray *templates = [NSPredicateEditorRowTemplate templatesWithAttributeKeyPaths:keyPaths inEntityDescription:entityDescription];
    [allTemplates addObjectsFromArray:templates];
	
    [self.predicateEditor setRowTemplates:allTemplates];
    if (isFirstRun)
    {
        [self.predicateEditor addRow:self];
    }
    
	[NSApp beginSheet:self.predicateSheet
	   modalForWindow:nil
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:nil];
}

- (IBAction)onPredicateEdited:(id)sender
{
    NSLog(@"onPredicateEdited: %@", [self.predicateEditor objectValue]);
    [self.generatedPredicateLabel setStringValue:[self.predicateEditor objectValue]];
}

- (IBAction)closePredicateSheet:(id)sender
{
    [self applyPredicate:sender];
    [self.coreDataIntrospection updateCoreDataHistory:[[self getEntityForPredicateEditor] name] :[self.predicateEditor objectValue]];
    [self enableDisableHistorySegmentedControls];
    
    [NSApp endSheet:self.predicateSheet];
	[self.predicateSheet orderOut:sender];
}

- (IBAction)cancelPredicateEditing:(id)sender
{
    [self.coreDataIntrospection applyPredicate:[[self getEntityForPredicateEditor] name] predicate:nil];
    
    [self.entityContentTable reloadData];
    
    [NSApp endSheet:self.predicateSheet];
	[self.predicateSheet orderOut:sender];
}

- (IBAction)applyPredicate:(id)sender
{
    [self.generatedPredicateLabel setStringValue:[self.predicateEditor objectValue]];
    [self.coreDataIntrospection applyPredicate:[[self getEntityForPredicateEditor] name] predicate:[self.predicateEditor objectValue]];
    [self.entityContentTable reloadData];
}

#pragma mark - Split view

- (BOOL) splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (BOOL) splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedPosition > 250.0 ? proposedPosition : 250.0;
}

@end
