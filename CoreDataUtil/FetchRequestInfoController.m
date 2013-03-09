//
//  FetchRequestInfoController.m
//  CoreDataUtil
//
//  Created by Denis Lebedev on 3/9/13.
//  Copyright (c) 2013 mFluent LLC. All rights reserved.
//

#import "FetchRequestInfoController.h"
#import "GetInfoSheetController.h"

@interface FetchRequestInfoController ()

@property (strong) NSFetchRequest *fetchRequest;
@property (strong) NSString *templateTitle;

- (void)addTableColumnWithIdentifier:(NSString *)ident;

@end

@implementation FetchRequestInfoController

- (void)initialize
{
	self.fetchTemplateNameTextField.stringValue = self.templateTitle;
	self.predicateTextField.stringValue = [self.fetchRequest.predicate predicateFormat];
	[self.entityButton setTitle:[self.fetchRequest.entity name]];
	
	[self addTableColumnWithIdentifier:@"Property"];
    [self addTableColumnWithIdentifier:@"Value"];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[self initialize];
}

- (void)show:(NSWindow *)sender forFetchRequest:(NSFetchRequest *)initial title:(NSString *)title
{
	self.fetchRequest = initial;
	self.templateTitle = title;
    
    [NSApp beginSheet:self.window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}

- (IBAction)closeAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

- (IBAction)entityClickAction:(NSButton *)sender
{
	GetInfoSheetController* infoSheetController = [[GetInfoSheetController alloc] initWithWindowNibName:@"GetInfoSheetController"];
    [infoSheetController show:self.window :self.fetchRequest.entity];
}

#pragma mark
#pragma NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 3;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"Property"])
    {
		switch (rowIndex) {
			case 0:
				return @"Result Type";
			case 1:
				return @"Fetch Limit";
			case 2:
				return @"Batch Size";
		}
    }
    else
    {
        switch (rowIndex) {
			case 0:
				return [self stringResultType:self.fetchRequest.resultType];
			case 1:
				return @(self.fetchRequest.fetchLimit);
			case 2:
				return @(self.fetchRequest.fetchBatchSize);
		}
    }
	return nil;
}

#pragma mark
#pragma NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}


- (void)addTableColumnWithIdentifier:(NSString *)ident
{
    NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier:ident];
    
    [[newColumn headerCell] setTitle:ident];
	if ([ident isEqualToString:@"Property"])
	{
		newColumn.width = 200;
	} else
	{
		[newColumn sizeToFit];
	}
    
    [[self fetchPropertiesTableView] addTableColumn:newColumn];
}

#pragma mark 
#pragma Private

- (NSString *)stringResultType:(NSFetchRequestResultType)type
{
	if (type == NSManagedObjectResultType) {
		return @"NSManagedObjectResultType";
	}
	if (type == NSManagedObjectIDResultType) {
		return @"NSManagedObjectIDResultType";
	}
	if (type == NSDictionaryResultType) {
		return @"NSDictionaryResultType";
	}
	if (type == NSCountResultType) {
		return @"NSCountResultType";
	}
	return nil;
}
@end
