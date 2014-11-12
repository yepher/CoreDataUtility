//
//  MFLMainWindowController.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/25/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLMainWindowController.h"
#import "CoreDataUtilityStyle.h"
#import "MFLConstants.h"
#import "EntityDataTableView.h"
#import "MFLTextTableCellView.h"
#import "MFLEntityTableCellView.h"
#import "MFLButtonTableViewCell.h"
#import "TransformableDataTableViewCell.h"
#import "MFLCellBuilder.h"
#import "OpenFileSheetController.h"
#import "GetInfoSheetController.h"
#import "FetchRequestInfoController.h"
#import "ObjectInfoController.h"
#import "MFLUtils.h"

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
@property NSDateFormatter *dateFormatter;

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
    
    //CGFloat defaultColWidth = [newColumn width];
    [newColumn sizeToFit];

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
	[self.historySegmentedControl setEnabled:[self canEnableBackHistoryControl] forSegment:0];
	[self.historySegmentedControl setEnabled:[self canEnableForwardHistoryControl] forSegment:1];
}

- (void) resotreEntitySelectionForHistoryObject:(CoreDataHistoryObject *)historyObject {
    OutlineViewNode *(^find)(OutlineViewNode *, NSString *);
    __block OutlineViewNode *(^ __weak findWeak)(OutlineViewNode *, NSString *);
    findWeak = find = ^OutlineViewNode *(OutlineViewNode *node, NSString *title) {
        if ([node.title isEqualToString:title]) {
            return node;
        }
        
        for (OutlineViewNode *child in node.childs) {
            OutlineViewNode *result = findWeak(child, title);
            if (result) {
                return result;
            }
        }
        
        return nil;
    };
    
    OutlineViewNode *node = find(self.rootNode, historyObject.name);
    
    if (node) {
        [self.dataSourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.dataSourceList rowForItem:node]] byExtendingSelection:NO];
    }
}

#pragma mark
#pragma mark NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //NSLog(@"- (void)tableViewSelectionDidChange:[%@]", aNotification);
    if ([self.dataSourceList isEqualTo:[aNotification object]])
    {
        [self onEntitySelected];
    }
}

- (void)onEntitySelected {
    if ([self.dataSourceList selectedRow] >= 0)
    {
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        [self.coreDataIntrospection clearEntityData];
        [self.entityContentTable reloadData];
        [self removeColumns];

        self.sortType = Unsorted;
        OutlineViewNode *selectedNode = [self.dataSourceList itemAtRow:[self.dataSourceList selectedRow]];

        NSInteger selected = selectedNode.index;
        NSInteger section = selectedNode.parent.index;
        if (selected >= 0 && section == 0)
        {
            [self.coreDataIntrospection loadEntityDataAtIndex:selected];
            NSArray* columnNames = [self.coreDataIntrospection entityFieldNames:[self.coreDataIntrospection entityAtIndex:selected]];
            for (NSString* name in columnNames)
            {
                [self addTableColumnWithIdentifier:name];
            }

            // TODO - why was this called twice?
            //[self.coreDataIntrospection loadEntityDataAtIndex:selected];
            [self.coreDataIntrospection updateCoreDataHistory:[self.coreDataIntrospection entityAtIndex:selected] predicate:nil objectType:MFLObjectTypeEntity];

        } else if (selected >= 0 && section == 1)
        {
            NSFetchRequest *fetch = [self.coreDataIntrospection fetchRequest:selected];
            NSArray* columnNames = [self.coreDataIntrospection entityFieldNames:[fetch.entity name]];
            for (NSString* name in columnNames)
            {
                [self addTableColumnWithIdentifier:name];
            }
            [self.coreDataIntrospection executeFetch:fetch];
            [self.coreDataIntrospection updateCoreDataHistory:[self.coreDataIntrospection fetchRequestAtIndex:selected]
                                                    predicate:[[self.coreDataIntrospection fetchRequest:selected] predicate]
                                                   objectType:MFLObjectTypeFetchRequest];
        }

        // allow main thread to return before calling reloadData again. user will see a faster table selection & an empty table view - then data will populate
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.entityContentTable reloadData];
        }];

        [self enableDisableHistorySegmentedControls];
        NSLog(@"Selected %@, selected=%d, section:%d, %@ms", selectedNode.title, (int)selected, (int)section, [MFLUtils duration:startTime]);
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
    NSInteger normalizedRow = [self sortOrderedRow:tableView row:row];
    NSArray *dataRow = [self.coreDataIntrospection getDataAtRow:(NSUInteger)normalizedRow];
    id valueObj = [dataRow valueForKey:[tableColumn identifier]];
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

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
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
    else if (tableView == [self entityContentTable])
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
            if ([cellText hasPrefix:@"http"]) {
                MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                buttonCell.wantsLayer = YES;
                [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                [[buttonCell infoField] setStringValue: cellText];
                return buttonCell;
            }
            else {
                MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
                return textCell;
            }
        }
        else if ([valueObj isKindOfClass:[NSURL class]])
        {
            NSURL* url = (NSURL*) valueObj;
            NSString* cellText = [NSString stringWithFormat:@"%@", [url absoluteString]];
            MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
            buttonCell.wantsLayer = YES;
            [[buttonCell infoField] setTextColor:[NSColor blackColor]];
            [[buttonCell infoField] setStringValue: cellText];
            return buttonCell;
        }
        else if ([valueObj isKindOfClass:[NSDate class]])
        {
            [self setupDateFormatter];
            NSString *cellText = [self.dateFormatter stringFromDate:valueObj];
            MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSData class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%ld", [valueObj length]];
            MFLTextTableCellView* textCell = [MFLCellBuilder numberCellWithString:tableView textToSet:cellText owner: self];
            textCell.wantsLayer = YES;
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSNumber class]])
        {
            NSString* cellText;
            NSNumber *number = valueObj;
            // get 'type' of NSNumber to determine if this is a Boolean data type
            if (strcmp(number.objCType, @encode(BOOL)) == 0) {
                cellText = [NSString stringWithFormat:@"%@", number.boolValue ? @"YES" : @"NO"];
            }
            else {
                cellText = [NSString stringWithFormat:@"%@", valueObj];
            }
            MFLTextTableCellView* textCell = [MFLCellBuilder numberCellWithString:tableView textToSet:cellText owner:self];
            textCell.wantsLayer = YES;
            return textCell;
        }
        else if ([valueObj isKindOfClass:[NSManagedObject class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%@", [[valueObj entity] name]];
            MFLButtonTableViewCell* buttonCell = [MFLCellBuilder objectCellWithString:tableView textToSet:cellText owner:self];
            buttonCell.wantsLayer = YES;
            return buttonCell;
        }
        else if ([valueObj isKindOfClass:[NSSet class]])
        {
            if ([valueObj count] > 0)
            {
                id obj = [valueObj anyObject];
                if ([obj isKindOfClass:[NSManagedObject class]]) {
                    NSManagedObject* object = obj;
                    NSString *cellText = [NSString stringWithFormat:@"%@[%ld]", [[object entity] name], [valueObj count]];
                    
                    MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                    buttonCell.wantsLayer = YES;
                    [[buttonCell infoField] setAlignment:NSRightTextAlignment];
                    [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                    [[buttonCell infoField] setStringValue: cellText];
                    return buttonCell;
                } else {
                    NSString *cellText = [NSString stringWithFormat:@"%@", valueObj];
                    MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
                    return textCell;
                }
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
                id obj = [valueObj firstItem];
                if ([obj isKindOfClass:[NSManagedObject class]]) {
                    NSManagedObject* object = obj;
                    NSString *cellText = [NSString stringWithFormat:@"%@[%ld]", [[object entity] name], [valueObj count]];
                    
                    MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                    buttonCell.wantsLayer = YES;
                    [[buttonCell infoField] setAlignment:NSRightTextAlignment];
                    [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                    [[buttonCell infoField] setStringValue: cellText];
                    return buttonCell;
                } else {
                    NSString *cellText = [NSString stringWithFormat:@"%@", valueObj];
                    MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
                    textCell.wantsLayer = YES;
                    return textCell;
                }
            }
            else // Empty NSArray
            {
                MFLTextTableCellView* textCell = [MFLCellBuilder nullCell:tableView owner:self];
                return textCell;
            }
        }
        else if ([valueObj isKindOfClass:[NSOrderedSet class]])
        {
            if ([valueObj count] > 0)
            {
                id obj = [valueObj firstObject];
                if ([obj isKindOfClass:[NSManagedObject class]]) {
                    NSManagedObject* object = obj;
                    NSString *cellText = [NSString stringWithFormat:@"%@[%ld]", [[object entity] name], [valueObj count]];
                    
                    MFLButtonTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_BUTTON_CELL owner:self];
                    buttonCell.wantsLayer = YES;
                    [[buttonCell infoField] setAlignment:NSRightTextAlignment];
                    [[buttonCell infoField] setTextColor:[NSColor blackColor]];
                    [[buttonCell infoField] setStringValue: cellText];
                    return buttonCell;
                } else {
                    NSString *cellText = [NSString stringWithFormat:@"%@", valueObj];
                    MFLTextTableCellView* textCell = [MFLCellBuilder textCellWithString:tableView textToSet:cellText owner:self];
                    textCell.wantsLayer = YES;
                    return textCell;
                }
            }
            else // Empty NSSet
            {
                MFLTextTableCellView* textCell = [MFLCellBuilder nullCell:tableView owner:self];
                return textCell;
            }
        }
        else if ([valueObj isKindOfClass:[NSDictionary class]])
        {
            NSString* cellText = [NSString stringWithFormat:@"%@", @"NSDictionary Data"];
            TransformableDataTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_TRANSFORM_CELL owner:self];
            buttonCell.wantsLayer = YES;
            [[buttonCell infoField] setAlignment:NSRightTextAlignment];
            [[buttonCell infoField] setTextColor:[NSColor blackColor]];
            [[buttonCell infoField] setStringValue: cellText];
            return buttonCell;
        }
        // Unhandled types of content
        else
        {
            NSLog(@"Unknown content: %@", valueObj);
            NSString* cellText = [NSString stringWithFormat:@"??? %@ ???", [valueObj class]];
            TransformableDataTableViewCell* buttonCell = [tableView makeViewWithIdentifier:MFL_TRANSFORM_CELL owner:self];
            buttonCell.wantsLayer = YES;
            [[buttonCell infoField] setAlignment:NSRightTextAlignment];
            [[buttonCell infoField] setTextColor:[NSColor blackColor]];
            [[buttonCell infoField] setStringValue: cellText];
            return buttonCell;
        }
    }
    
    return nil;
}

- (void)setupDateFormatter {
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
    }
    switch (self.dateStyle) {
        case NSDateFormatterShortStyle:
            [self.dateFormatter setDateFormat:@"M/d/YY h:mm a"];
            break;
        case NSDateFormatterMediumStyle:
            [self.dateFormatter setDateFormat:@"MM/dd/YY hh:mm a"];
            break;
        default:
            // use original formatting
            [self.dateFormatter setDateStyle:self.dateStyle];
            [self.dateFormatter setTimeStyle:self.dateStyle];
            break;
    }
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
		if ([self.rootNode.childs[1] hasChild:node]) {
			cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
			cell.textField.stringValue = node.title;
			cell.imageView.image = [CoreDataUtilityStyle imageOfFetch];
			NSButton *button = [cell viewWithTag:1];
			[button removeFromSuperview];
		} else {
			cell = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
			cell.textField.stringValue = node.title;
			cell.imageView.image = [CoreDataUtilityStyle imageOfEntity];
			NSButton *button = [cell viewWithTag:1];
			button.title = [NSString stringWithFormat:@"%d", node.badgeValue];
		}
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

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification {
    [self tableViewSelectionDidChange:notification];
}

#pragma mark - 
#pragma mark Helpers

- (void)configureOutlineViewNodes {
	self.rootNode = [OutlineViewNode new];
    self.rootNode.index = 0;
    self.rootNode.title = @"";
    
    OutlineViewNode *entitiesNode = [OutlineViewNode new];
    entitiesNode.title = @"entities";
    entitiesNode.index = 0;
    [self.rootNode addChild:entitiesNode];
	
    NSUInteger entityCount = self.coreDataIntrospection.entityCount;
    for(int i=0; i<entityCount; i++) {
        OutlineViewNode *node = [OutlineViewNode new];
        node.title = [self.coreDataIntrospection entityAtIndex:i];
        node.index = i;
        node.badgeValue = (int)[self.coreDataIntrospection entityDataCountAtIndex:i];
        [entitiesNode addChild:node];
    }
    
	OutlineViewNode *fetchRequestNode = [OutlineViewNode new];
    fetchRequestNode.title = @"fetch requests";
    fetchRequestNode.index = 1;
    [self.rootNode addChild:fetchRequestNode];
	
	for(int i=0; i<self.coreDataIntrospection.fetchRequestCount; i++) {
        OutlineViewNode *node = [OutlineViewNode new];
        node.title = [self.coreDataIntrospection fetchRequestAtIndex:i];
        node.index = i;
        [fetchRequestNode addChild:node];
    }
	
    [self.dataSourceList reloadData];
    if (self.rootNode.childs.count > 0) {
        [self.dataSourceList expandItem:self.rootNode.childs[0]];
		[self.dataSourceList expandItem:self.rootNode.childs[1]];
    }
}

- (BOOL) openFiles:(NSURL*) momFile persistenceFile:(NSURL*) persistenceFile persistenceType:(NSInteger) persistenceType
{
    [self.window makeKeyAndOrderFront:self];
    
    [self openCoreDataIntrospectionWithUrls:momFile persistFileUrl:persistenceFile persistFormat:persistenceType];
    
	[self configureOutlineViewNodes];

    [self.entityContentTable reloadData];
    [self enableDisableHistorySegmentedControls];

    self.projectFile = nil;

    return YES;
}

- (BOOL) openProject:(NSString *)filename
{
    NSLog(@"Load Project File: [%@]", filename);
    NSDictionary* project = [NSDictionary dictionaryWithContentsOfFile:filename];
    NSString* momFilePath = project[MFL_MOM_FILE_KEY];
    NSString* dbFilePath = project[MFL_DB_FILE_KEY];
    NSNumber* persistenceFormat = project[MFL_DB_FORMAT_KEY];
    if (persistenceFormat == nil) {
        persistenceFormat = @(MFL_SQLiteStoreType);
    }

    NSURL* momUrl = nil;
    NSURL* dbUrl = nil;
    if (momFilePath != nil) {
        momUrl = [NSURL URLWithString:momFilePath];
    }

    if (dbFilePath != nil) {
        dbUrl = [NSURL URLWithString:dbFilePath];
    }

    // if iOS, check if file exists otherwise search for it because it may have moved.
    NSError *err;
    if (![momUrl checkResourceIsReachableAndReturnError:&err]) {
        // is iOS Simulator?
        NSRange pathRange = [momFilePath rangeOfString:APPLICATIONS_DIR];
        if (pathRange.location != NSNotFound) {
            // This is an iOS simulator project
            NSLog(@"momPath: %@", momFilePath);
            NSString* applicationsPath = [self convertToIosApplicationsBasePath:momFilePath];
            NSString* relativeMomPath = [self convertToApplicationPath:momFilePath];
            NSString* relativeDBPath = [self convertToApplicationPath:dbFilePath];

            // Scan through UUID directories to see if any match our paths
            // Search through each UUID to find our files
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError* error;
            NSArray* contents = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:applicationsPath] includingPropertiesForKeys:@[NSURLFileResourceTypeDirectory] options:0 error:&error];
            for (NSString* content in contents) {
                NSLog(@"Found: %@", content);
                NSString* testMomPath = [NSString stringWithFormat:@"%@%@",content, relativeMomPath];
                NSURL* testMomUrl = [NSURL URLWithString:testMomPath];
                if ([testMomUrl checkResourceIsReachableAndReturnError:&err] == NO) {
                    continue;
                }

                NSString* testDBPath = [NSString stringWithFormat:@"%@%@", content, relativeDBPath];
                NSURL* testDBUrl = [NSURL URLWithString:testDBPath];
                if ([testDBUrl checkResourceIsReachableAndReturnError:&err] == NO) {
                    continue;
                }

                // Both files exist so use this path instead.
                momFilePath = testMomPath;
                dbFilePath = testDBPath;

                momUrl = [NSURL URLWithString:momFilePath];
                dbUrl = [NSURL URLWithString:dbFilePath];

                // Exit for loop
                break;
            }
        }
    }

    BOOL isOk = [self openFiles:momUrl persistenceFile:dbUrl persistenceType:persistenceFormat];
    if (isOk) {
        self.projectFile = filename;
    }
    return isOk;
}

- (NSString*) convertToIosApplicationsBasePath:(NSString*) filePath {
    NSRange pathRange = [filePath rangeOfString:APPLICATIONS_DIR];
    if (pathRange.location == NSNotFound) {
        return nil;
    }

    return [filePath substringToIndex:pathRange.location+pathRange.length];
}

- (NSString*) convertToApplicationPath:(NSString*) filePath {
    NSRange pathRange = [filePath rangeOfString:APPLICATIONS_DIR];
    if (pathRange.location == NSNotFound) {
        return nil;
    }

    NSUInteger len = ((pathRange.location+pathRange.length) +36);

    if ([filePath length] <= len) {
        return nil;
    }

    return [filePath substringFromIndex:len];
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
    OutlineViewNode *selectedNode = [self.dataSourceList itemAtRow:[self.dataSourceList selectedRow]];
    NSInteger selected = selectedNode.index;
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
    if (selected < 0) {
        NSLog(@"getInfoAction: bad index:%d", (int)selected);
        return;
    }
    NSEntityDescription* entityDescription = [self.coreDataIntrospection entityDescription:selected];
    
    GetInfoSheetController* infoSheetController = [[GetInfoSheetController alloc] initWithWindowNibName:@"GetInfoSheetController"];
    [infoSheetController show:self.window :entityDescription];
}

- (void)getFetchRequestInfoAction
{
	//@TODO: convert section/row to correct selected index
    NSInteger selected = [[self dataSourceList] getRightClickedRow] - self.coreDataIntrospection.entityCount - 2;
	NSFetchRequest *fetchRequest = [self.coreDataIntrospection fetchRequest:selected];
	FetchRequestInfoController *fetchRequestController = [[FetchRequestInfoController alloc] initWithWindowNibName:@"FetchRequestInfoController"];
	[fetchRequestController show:self.window forFetchRequest:fetchRequest title:[self.coreDataIntrospection fetchRequestAtIndex:selected]];
}

#pragma mark -
#pragma mark IBActions

- (void)reloadEntityDataTable:(NSString *)name predicate:(NSPredicate *)predicate type:(MFLObjectType)type
{
    [self removeColumns];
    [self.coreDataIntrospection clearEntityData];
    [self.entityContentTable reloadData];
    self.sortType = Unsorted;
	
	if (type == MFLObjectTypeFetchRequest) {
		NSFetchRequest *request = [self.coreDataIntrospection fetchRequestWithName:name];
		name = [[request entity] name];
	}
    
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

- (IBAction)infoCellButtonClicked:(id)sender
{
    NSInteger row = [self.entityContentTable rowForView:sender];
    NSInteger column = [self.dataSourceList columnForView:sender];
    NSArray *columns = [self.entityContentTable tableColumns];
    
    id valueObj = [self getValueObjFromDataRows:self.entityContentTable :row :columns[column]];
    
    if (valueObj != nil) {
        ObjectInfoController* infoSheetController = [[ObjectInfoController alloc] initWithWindowNibName:@"ObjectInfoController"];
        [infoSheetController show:self.window objectDescription:[valueObj description]];
    }
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
            [self reloadEntityDataTable:[[managedObject entity] name] predicate:predicate type:MFLObjectTypeEntity];
            [self.coreDataIntrospection updateCoreDataHistory:[[managedObject entity] name] predicate:predicate objectType:MFLObjectTypeEntity];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", array];
            [self reloadEntityDataTable:[[array[0] entity] name] predicate:predicate type:MFLObjectTypeEntity];
            [self.coreDataIntrospection updateCoreDataHistory:[[array[0] entity] name] predicate:predicate objectType:MFLObjectTypeEntity];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSSet class]])
        {
            NSSet *set = (NSSet *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", set];
            [self reloadEntityDataTable:[[[set anyObject] entity] name] predicate:predicate type:MFLObjectTypeEntity];
            [self.coreDataIntrospection updateCoreDataHistory:[[[set anyObject] entity] name] predicate:predicate objectType:MFLObjectTypeEntity];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSOrderedSet class]])
        {
            NSOrderedSet *set = (NSOrderedSet *)valueObj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", set];
            [self reloadEntityDataTable:[[[set firstObject] entity] name] predicate:predicate type:MFLObjectTypeEntity];
            [self.coreDataIntrospection updateCoreDataHistory:[[[set firstObject] entity] name] predicate:predicate objectType:MFLObjectTypeEntity];
            [self enableDisableHistorySegmentedControls];
        }
        else if ([valueObj isKindOfClass:[NSString class]]) {
            NSString *string = valueObj;
            if ([string hasPrefix:@"http"]) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:string]];
            }
        }
        else if ([valueObj isKindOfClass:[NSURL class]]) {
            NSURL *url = valueObj;
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
    }
}



- (IBAction) historyToolbarItemSelected:(id)sender
{
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSInteger currentIndex = [self.coreDataIntrospection getCurrentHistoryIndex];
    CoreDataHistoryObject *historyObj;
    
    // go back
    if ([control selectedSegment] == 0 && [self canEnableBackHistoryControl])
    {
        [self.coreDataIntrospection setCurrentHistoryIndex:currentIndex+1];
        historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
        [self reloadEntityDataTable:historyObj.name predicate:historyObj.predicate type:historyObj.type];
        [self enableDisableHistorySegmentedControls];
    }
    // go forward
    else if ([control selectedSegment] == 1 && [self canEnableForwardHistoryControl])
    {
        [self.coreDataIntrospection setCurrentHistoryIndex:currentIndex-1];
        historyObj = (self.coreDataIntrospection.coreDataHistory)[[self.coreDataIntrospection getCurrentHistoryIndex]];
        [self reloadEntityDataTable:historyObj.name predicate:historyObj.predicate type:historyObj.type];
        [self enableDisableHistorySegmentedControls];
    }
    
    [self resotreEntitySelectionForHistoryObject:historyObj];
}

- (IBAction) refreshItemSelected:(id)sender
{
    if (self.coreDataIntrospection == nil) {
        return;
    }
    // backup last selected entity
    NSInteger selectedRow = [self.dataSourceList selectedRow];

    NSLog(@"refreshItemSelected: selectedRow:%d", (int)selectedRow);

    // if loaded from project file, reload from same file. allows updating URL's in project file while running
    if (self.projectFile != nil) {
        [self openProject:self.projectFile];
    }
    else {
        [self.coreDataIntrospection reloadObjectModel];
        [self configureOutlineViewNodes];
        [self.entityContentTable reloadData];
        [self enableDisableHistorySegmentedControls];
    }

    if (selectedRow >= 0) {
        // restore selection
        [self.dataSourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger) selectedRow] byExtendingSelection:NO];
        [self onEntitySelected];
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
            entityDescription = [self.coreDataIntrospection entityDescriptionForName:historyObj.name];
        }
    }
    
    return entityDescription;
}

- (IBAction)showPredicateEditor:(id)sender
{    
    
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
    [self.coreDataIntrospection updateCoreDataHistory:[[self getEntityForPredicateEditor] name] predicate:[self.predicateEditor objectValue] objectType:MFLObjectTypeEntity];
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

#pragma mark - EntityTableViewDataSource 

- (NSInteger)sectionIndexForRow:(NSInteger)row {
	OutlineViewNode *nodeAtRow = [self.dataSourceList itemAtRow:row];
	return nodeAtRow.parent.index;
}

- (NSSet *)tableSectionIndexes {
	NSMutableArray *result = [NSMutableArray array];
	for (OutlineViewNode *sectionNode in self.rootNode.childs) {
		[result addObject:@([self.dataSourceList rowForItem:sectionNode])];
	}
	return [NSSet setWithArray:[result copy]];
}

@end
