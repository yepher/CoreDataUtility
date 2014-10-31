//
//  SimulatorItem.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 10/27/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import "SimulatorItem.h"

#define IsALeafNode ((id)-1)

@implementation SimulatorItem

static SimulatorItem *rootItem = nil;

- (id)initWithPath:(NSString *)path parent:(SimulatorItem*) obj {
    if (self = [super init]) {
        if (obj == nil) {
            self.relativePath = path;
        } else {
            self.relativePath = [[path lastPathComponent] copy];
        }
        self.parent = obj;
        self.path = path;
    }
    return self;
}

+ (SimulatorItem*) rootItem {
    NSURL* simulatorUrl = [self simulatorRootDirectory];
    
    if (rootItem == nil) {
        rootItem = [[SimulatorItem alloc] initWithPath:[simulatorUrl path]  parent:nil];
        [rootItem setItemType:MFLRootItem];
    }
    return rootItem;
}

// Creates and returns the array of children
// Loads children incrementally
//
- (NSArray*)children {
    if (_children == nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
        if (valid && isDir) {
            NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
            if (!array) {   // This is unexpected
                self.children = [[NSMutableArray alloc] init];
            } else {
                NSInteger cnt, numChildren = [array count];
                self.children = [[NSMutableArray alloc] init];
                for (cnt = 0; cnt < numChildren; cnt++) {
                    NSString* simDir = [array objectAtIndex:cnt];
                    NSDictionary* simInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/device.plist", fullPath, simDir]];
                    if (simInfo != nil) {
                        SimulatorItem *item = [[SimulatorItem alloc] initWithPath:simDir parent:self];
                        [item setSimInfo:simInfo];
                        [item setItemType:MFLSimulatorItem];
                        [_children addObject:item];
                    } else if (self.itemType == MFLSimulatorItem ) {
                        // TODO: find applications
                        // .com.apple.mobile_container_manager.metadata.plist
                        
                        // /Users/chris/Library/Developer/CoreSimulator/Devices/615CF8CD-1286-4C83-9C62-0D5D690BF591/data/Containers/
                        // Bundle/Application/EA3C673A-627A-487A-A747-8D427FFA9FF6/Beepngo.app/Beepngo.momd/Beepngo.mom
                        // Data/Application/0F07363C-027C-40BD-AB46-769EC6F967E7/Documents/Beepngo.sqlite

                        // Data/Application/0F07363C-027C-40BD-AB46-769EC6F967E7/.com.apple.mobile_container_manager.metadata.plist
                        // MCMMetadataIdentifier
                        // UDID
//                        NSDictionary* simInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/.com.apple.mobile_container_manager.metadata.plist", fullPath, simDir]];
//                        if (simInfo != nil) {
//                            SimulatorItem *item = [[SimulatorItem alloc] initWithPath:simDir parent:self];
//                            [_children addObject:item];
//                        }
                    }
                }
            }
        } else {
            self.children = nil; //IsALeafNode;
        }
    }
    return _children;
}

- (NSString *)fullPath {
    return self.parent ? [[self.parent fullPath] stringByAppendingPathComponent:self.relativePath] : self.relativePath;
}

- (SimulatorItem*) childAtIndex:(NSInteger)n {
    return [[self children] objectAtIndex:n];
}

- (NSInteger) numberOfChildren {
    id tmp = [self children];
    return (tmp == nil) ? (-1) : [tmp count];
}

- (NSString*) label {
    if (self.simInfo != nil) {
        return [self.simInfo valueForKey:@"name"];
    }
    
    return [self.path lastPathComponent];
}

#pragma mark - Internal Helpers

+ (NSURL *)simulatorRootDirectory {
    // Root: /Users/chris/Library/Developer/CoreSimulator/Devices

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL* libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* simulatorUrl = [libraryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/Developer/CoreSimulator/Devices"]];
    return simulatorUrl;
}


@end
