//
//  MFLCoreDataEditorProjectLoader.h
//  CoreDataUtil
//
//  Created by Chris Wilson on 6/27/12.
//  Copyright (c) 2012 mFluent LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFLCoreDataEditorProjectLoader : NSObject

- (NSDictionary*) decodeProjectFile: (NSString*) projectFilePath;

@end
