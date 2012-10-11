//
//  MFLInAppPurchaseHelper.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/28/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLInAppPurchaseHelper.h"
#import "MFLConstants.h"

@implementation MFLInAppPurchaseHelper

- (id)initWithProductIdentifiers:(NSSet *)productIds
{
    if ((self = [super init]))
    {
        _productIdentifiers = productIds;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased)
            {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
    }
    
    return self;
}

- (void)requestProducts
{    
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _request.delegate = self;
    [_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Received product results...");
    NSLog(@"response products = %@", response.products);
    NSLog(@"Invalid identifiers = %@", response.invalidProductIdentifiers);
    self.products = response.products;
    
    self.request = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MFL_kProductsLoadedNotification object:_purchasedProducts];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // Optional: Record the transaction on the server side...    
}

- (void)provideContent:(NSString *)productIdentifier {
    
    NSLog(@"Toggling flag for: %@", productIdentifier);
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MFL_kProductPurchasedNotification object:productIdentifier];
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MFL_kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                // ignore
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                NSLog(@"Uh Oh! Not sure what happened here!!! [%ld]", transaction.transactionState);
                break;
        }
    }
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying: %@", product.productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (void)restoreProducts {
    
    NSLog(@"restoreCompletedTransactions");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL) isFullVersion {
#ifdef FORCE_FULL_VERSION
    return YES;
#endif
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:MFL_FULL_VERSION_IDENTIFIER];
}

@end
