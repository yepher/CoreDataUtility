//
//  CoreDataHistoryObject.m
//  CoreDataUtil
//
//  Created by Laurie Caires on 6/28/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import "CoreDataHistoryObject.h"

@implementation CoreDataHistoryObject

- (BOOL)isEqualTo:(id)object
{
    if ([object isKindOfClass:[CoreDataHistoryObject class]])
    {
        CoreDataHistoryObject *historyObj = (CoreDataHistoryObject *)object;
        if ([self.name isEqualToString:historyObj.name] &&
            ((self.predicate == nil && historyObj.predicate == nil) || ([self.predicate isEqualTo:historyObj.predicate])) &&
			self.type == historyObj.type)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
