//
//  MFLInAppPurchaseHelper.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/28/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

@interface MFLInAppPurchaseHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSSet * _productIdentifiers;    
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
}

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)restoreProducts;
- (void)buyProduct:(SKProduct *)product;

/*
 This indicates the user has purchased the full feature set
 
 */
- (BOOL) isFullVersion;

@end


