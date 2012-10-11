//
//  EntityDataTableView.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/6/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "EntityDataTableView.h"
#import "MFLButtonTableViewCell.h"
#import "MFLMainWindowController.h"
#import "InAppPurchaseWindowController.h"

@implementation EntityDataTableView

- (NSInteger)getRightClickedCol
{
    return rightClickedCol;
}

- (NSInteger)getRightClickedRow
{
    return rightClickedRow;
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    NSMenu *menu = nil;
    
    NSIndexSet* indexSet = [self selectedRowIndexes];
    if (indexSet != nil && [indexSet firstIndex] != NSNotFound) {
        menu = [[NSMenu alloc] init];
        NSMenuItem* copyRowItem = [[NSMenuItem alloc] initWithTitle:@"Copy Plain" action:@selector(copy:) keyEquivalent:@""];
        [copyRowItem setKeyEquivalentModifierMask:0];
        [copyRowItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [menu addItem:copyRowItem]; 
        
        copyRowItem = [[NSMenuItem alloc] initWithTitle:@"Copy Formated" action:@selector(copyFormatted:) keyEquivalent:@"C"];
        [copyRowItem setKeyEquivalentModifierMask:0];
        [copyRowItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [menu addItem:copyRowItem]; 
        
    }
    
    return menu;
}

/**
 Copy the single selected row from the table. 
 The elements are separated by newlines, as text (!{NSStringPboardType}), 
 and by tabs, as tabular text (!NSTabularTextPboardType).
 
 **/
- (void) copySelectedRow: (BOOL) escapeSpecialChars {
    int selectedRow = (int)[self selectedRow]-1;
    int	numberOfRows = (int)[self numberOfRows];
    
    NSLog(@"Selected Row: %d, Total Rows: %d", selectedRow, numberOfRows);
    
    NSIndexSet* indexSet = [self selectedRowIndexes];
    if (indexSet != nil && [indexSet firstIndex] != NSNotFound) {
        NSPasteboard	*pb = [NSPasteboard generalPasteboard];
        NSMutableString *tabsBuf = [NSMutableString string];
        NSMutableString *textBuf = [NSMutableString string];
        
        NSArray *tableColumns = [self tableColumns];
        NSLog(@"Columns: %@", tableColumns);
        
        for (NSTableColumn* columnName in tableColumns) {
            [textBuf appendFormat:@"%@\t", [columnName identifier] ];
            [tabsBuf appendFormat:@"%@\t", [columnName identifier]];
        }
        
        [textBuf appendFormat:@"\n"];
        [tabsBuf appendFormat:@"\n"];

        // Step through and copy data from each of the selected rows
        NSUInteger currentIndex = [indexSet firstIndex];
        while (currentIndex != NSNotFound) {

            NSEnumerator *enumerator = [tableColumns objectEnumerator];
            NSTableColumn *col;
            MFLMainWindowController* dataSource = (MFLMainWindowController*)[self dataSource];
            while (nil != (col = [enumerator nextObject]) ) {
                id columnValue = [dataSource getValueObjFromDataRows:self: currentIndex: col];
                NSString *columnString = @"";
                if (nil != columnValue) {
                    if ([columnValue isKindOfClass:[NSManagedObject class]]) {
                        columnString = [[columnValue entity] name];
                    } else if ([columnValue isKindOfClass:[NSArray class]]) {
                        columnString = [NSString stringWithFormat:@"NSArray[%ld]", [columnValue count]];
                    } else if ([columnValue isKindOfClass:[NSSet class]]) {
                        columnString = [NSString stringWithFormat:@"NSSet[%ld]", [columnValue count]];
                    } else {
                        
                        columnString = [columnValue description];
                    }
                }
                
                if (columnString == nil) {
                    columnString = @"";
                }
                
                if (escapeSpecialChars) {
                    // Escape CR and TAB like SQLPro:
                    //    http://code.google.com/p/sequel-pro/source/browse/branches/app-store/Source/SPCopyTable.m?r=3592#239
                    columnString = [[columnString stringByReplacingOccurrencesOfString:@"\n" withString:@"↵"] stringByReplacingOccurrencesOfString:@"\t" withString:@"⇥"];
                }
                
                [tabsBuf appendFormat:@"%@\t",columnString];
                [textBuf appendFormat:@"%@\t",columnString];
            }
            
            [textBuf appendFormat:@"\n"];
            [tabsBuf appendFormat:@"\n"];
            // delete the last tab. (But don't delete the last CR)
            if ([tabsBuf length]) {
                [tabsBuf deleteCharactersInRange:NSMakeRange([tabsBuf length]-1, 1)];
            }
            
            // Next Index
            currentIndex = [indexSet indexGreaterThanIndex: currentIndex];
        }
        [pb declareTypes:@[NSStringPboardType] owner:nil];
        [pb setString:[NSString stringWithString:textBuf] forType:NSStringPboardType];
    }
}

- (BOOL) isFUllVersion {

    // if Copy is not already purchased, prompt user to buy it
    if ([[MFLInAppPurchaseHelperSubclass sharedHelper] isFullVersion] == NO) {
        InAppPurchaseWindowController* inAppPurchaseSheetController = [[InAppPurchaseWindowController alloc] initWithWindowNibName:@"InAppPurchaseWindowController"];
        [inAppPurchaseSheetController show:self.window];
        inAppPurchaseSheetController = nil;
    }
    return [[MFLInAppPurchaseHelperSubclass sharedHelper] isFullVersion];
}

- (IBAction) copy:(id)sender
{
    // if the in-app purchase is not already purchased, prompt user to buy it
    if ([self isFUllVersion] == NO) {
        return;
    }

    NSLog(@"Copy Selected entityDataTable items. [%@]", sender);
    [self copySelectedRow:NO];
}

- (IBAction) copyFormatted:(id)sender
{
    if ([self isFUllVersion] == NO) {
        return;
    }
    
    NSLog(@"copyFormated Selected entityDataTable items. [%@]", sender);
    [self copySelectedRow:YES];
}

@end
