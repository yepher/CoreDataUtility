//
//  MFLInAppPurchaseHelperSubclass.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/29/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "MFLInAppPurchaseHelperSubclass.h"
#import "MFLConstants.h"

@implementation MFLInAppPurchaseHelperSubclass

static MFLInAppPurchaseHelperSubclass * _sharedHelper;

+ (MFLInAppPurchaseHelperSubclass *) sharedHelper
{    
    if (_sharedHelper != nil)
    {
        return _sharedHelper;
    }
    
    _sharedHelper = [[MFLInAppPurchaseHelperSubclass alloc] init];
    return _sharedHelper;
}

- (id)init
{    
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 MFL_FULL_VERSION_IDENTIFIER,
                                 nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers]))
    {                
        
    }
    
    return self;
}

@end
