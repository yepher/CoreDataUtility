//
//  InAppPurchaseWindowController.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/29/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "InAppPurchaseWindowController.h"
#import "MFLConstants.h"

@interface InAppPurchaseWindowController ()


@end

@implementation InAppPurchaseWindowController

@synthesize inAppPurchaseTableView;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowWillLoad
{
    self.inAppPurchaseTableView.hidden = TRUE;
    
    if ([MFLInAppPurchaseHelperSubclass sharedHelper].products == nil)
    {
        [[MFLInAppPurchaseHelperSubclass sharedHelper] requestProducts];
    }
}


- (void)windowDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:MFL_kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindow:) name:MFL_kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:MFL_kProductPurchaseFailedNotification object:nil];
    
    [super windowDidLoad];
}

- (void) closeWindow:(NSNotification *)notification {
    [NSApp stopModal];
    [self.window close];
    
}

- (void) showAlertAndCloseWindow: (SKPaymentTransaction*) transaction {
    NSLog(@"Transaction failed: [%@]\n%@", transaction, transaction.error.localizedDescription);
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setMessageText:@"Item Purchase Failed"];
//    [alert setInformativeText:transaction.error.localizedDescription];
//    [alert setAlertStyle:NSWarningAlertStyle];
//    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:nil];
    
    [self closeWindow:nil];

}

- (void) purchaseFailed:(NSNotification*) notification {
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        [self performSelectorOnMainThread:@selector(showAlertAndCloseWindow:) withObject:transaction waitUntilDone:NO];
    } else {
        NSLog(@"SKErrorPaymentCancelled");
        [self closeWindow:notification];
    }
    
    
}


- (void)productsLoaded:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.inAppPurchaseTableView.hidden = FALSE;    
    [self.inAppPurchaseTableView reloadData];
    
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[MFLInAppPurchaseHelperSubclass sharedHelper].products count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{    
    SKProduct *product = [[MFLInAppPurchaseHelperSubclass sharedHelper].products objectAtIndex:row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    InAppPurchaseTableCellView *buttonCell = [MFLCellBuilder inAppPurchaseCellWithString:tableView :product.localizedTitle :formattedString :row :self];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    return buttonCell;
}

- (void)show:(NSWindow *)sender
{
    [NSApp beginSheet:self.window modalForWindow:sender modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:self.window];
	// sheet is up here...
    
    [NSApp endSheet:self.window];
	[self.window orderOut:self];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)inAppPurchaseCancelButtonAction:(id)sender
{
    [NSApp stopModal];
    [self.window close];
}

- (IBAction)restoreTransactionsAction:(id)sender {
    [[MFLInAppPurchaseHelperSubclass sharedHelper] restoreProducts];
}

- (IBAction)buyAction:(id)sender {
    
    NSInteger selectedRow = [[self inAppPurchaseTableView] selectedRow];

    if (selectedRow < 0) {
        return;
    }

    SKProduct *product = [[MFLInAppPurchaseHelperSubclass sharedHelper].products objectAtIndex:selectedRow];
    [[MFLInAppPurchaseHelperSubclass sharedHelper] buyProduct:product];
}


@end
