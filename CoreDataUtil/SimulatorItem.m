//
//  SimulatorItem.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 10/27/14.
//  Copyright (c) 2014 mFluent LLC. All rights reserved.
//

#import "SimulatorItem.h"

// Meta Data PList File
// .com.apple.mobile_container_manager.metadata.plist

// Application PList file
// .com.apple.mobile_container_manager.metadata.plist

// App Name Key
// MCMMetadataIdentifier

NSString *const APP_NAME_KEY = @"MCMMetadataIdentifier";
NSString *const APP_CONTAINER_PLIST = @".com.apple.mobile_container_manager.metadata.plist";

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
        
        if (self.itemType == MFLRootItem) {
            NSLog(@"Parent is RootItem so return simulators");
            _children = [self loadSimulators];
        } else if (self.itemType == MFLSimulatorItem) {
            NSLog(@"Parent is Simulator so return apps");
            _children = [self findApplicationsAtPath:self.fullPath];
            
        } else {
            NSLog(@"Unknown item type: %ld", self.parent.itemType);
        }
    }
    
    return _children;
    
}

//- (void) temp {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *fullPath = [self fullPath];
//        BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
//        if (valid && isDir) {
//            NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
//            if (!array) {   // This is unexpected
//                self.children = [[NSMutableArray alloc] init];
//            } else {
//                NSInteger cnt, numChildren = [array count];
//                self.children = [[NSMutableArray alloc] init];
//                for (cnt = 0; cnt < numChildren; cnt++) {
//                    NSString* simDir = [array objectAtIndex:cnt];
//                    NSDictionary* simInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/device.plist", fullPath, simDir]];
//                    if (simInfo != nil) {
//                        SimulatorItem *item = [[SimulatorItem alloc] initWithPath:simDir parent:self];
//                        [item setSimInfo:simInfo];
//                        [item setItemType:MFLSimulatorItem];
//                        [_children addObject:item];
//                    } else if (self.itemType == MFLSimulatorItem ) {
//                        // TODO: find applications
//                        // .com.apple.mobile_container_manager.metadata.plist
//                        
//                        // /Users/chris/Library/Developer/CoreSimulator/Devices/615CF8CD-1286-4C83-9C62-0D5D690BF591/data/Containers/
//                        // Bundle/Application/EA3C673A-627A-487A-A747-8D427FFA9FF6/Beepngo.app/Beepngo.momd/Beepngo.mom
//                        // Data/Application/0F07363C-027C-40BD-AB46-769EC6F967E7/Documents/Beepngo.sqlite
//
//                        // Data/Application/0F07363C-027C-40BD-AB46-769EC6F967E7/.com.apple.mobile_container_manager.metadata.plist
//                        // MCMMetadataIdentifier
//                        // UDID
////                        NSDictionary* simInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/.com.apple.mobile_container_manager.metadata.plist", fullPath, simDir]];
////                        if (simInfo != nil) {
////                            SimulatorItem *item = [[SimulatorItem alloc] initWithPath:simDir parent:self];
////                            [_children addObject:item];
////                        }
//                    }
//                }
//            }
//        } else {
//            self.children = nil; //IsALeafNode;
//        }
//    }
//    return _children;
//}

- (NSMutableArray*) loadSimulators {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [self fullPath];
    BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    
    NSMutableArray* simulators = [NSMutableArray array];
    if (valid && isDir) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        if (!array) {   // This is unexpected
            simulators = [[NSMutableArray alloc] init];
        } else {
            NSInteger cnt, numChildren = [array count];
            simulators = [[NSMutableArray alloc] init];
            for (cnt = 0; cnt < numChildren; cnt++) {
                NSString* simDir = [array objectAtIndex:cnt];
                NSDictionary* simInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/device.plist", fullPath, simDir]];
                if (simInfo != nil) {
                    SimulatorItem *item = [[SimulatorItem alloc] initWithPath:simDir parent:self];
                    [item setSimInfo:simInfo];
                    [item setItemType:MFLSimulatorItem];
                    [simulators addObject:item];
                }
            }
        }
    }

    
    return simulators;
}


- (NSMutableArray*) findApplicationsAtPath:(NSString*) path {
    /**
     <key>MCMMetadataIdentifier</key>
     <string>com.mobeam.Beepngo</string>
     **/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath =  [NSString stringWithFormat:@"%@/data/Containers/Bundle/Application", [self fullPath]];
    BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    NSMutableArray* applications = [NSMutableArray array];
    if (valid && isDir) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        
        for (NSString* appPath in array) {
            NSLog(@"appPath: %@", appPath);
            NSString* appBaseFolder = [NSString stringWithFormat:@"%@/%@",fullPath, appPath];
            NSString* metaFilePath = [NSString stringWithFormat:@"%@/%@", appBaseFolder, APP_CONTAINER_PLIST];
            NSLog(@"will scan %@", metaFilePath);
            NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:metaFilePath];
            if (dict != nil) {
                NSLog(@"found: %@", [dict objectForKeyedSubscript:APP_NAME_KEY]);
                SimulatorItem *item = [[SimulatorItem alloc] initWithPath:appPath parent:self];
                [item setFullAppPath:[self fileWithExtension:appBaseFolder : @".app"]];
                [item setSimInfo:dict];
                [item setAppPackage: [dict objectForKeyedSubscript:APP_NAME_KEY]];
                [item setItemType:MFLAppItem];
                [applications addObject:item];
            }
        }
    
    
    }
    
    return applications;
}

- (NSString*) findDocumentForApplication:(NSString*) appName atPath:(NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fullPath =  [NSString stringWithFormat:@"%@/data/Containers/Data/Application", path];
    BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    if (valid && isDir) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        
        for (NSString* appPath in array) {
            NSLog(@"appPath: %@", appPath);
            NSString* appBaseFolder = [NSString stringWithFormat:@"%@/%@",fullPath, appPath];
            NSString* metaFilePath = [NSString stringWithFormat:@"%@/%@", appBaseFolder, APP_CONTAINER_PLIST];
            NSLog(@"will scan %@", metaFilePath);
            NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:metaFilePath];
            if (dict != nil) {
                NSLog(@"found: %@", [dict objectForKeyedSubscript:APP_NAME_KEY]);
                if ([appName isEqualToString:[dict objectForKeyedSubscript:APP_NAME_KEY]]) {
                    return [NSString stringWithFormat:@"%@/Documents", appBaseFolder];
                }
            }
        }
    }
    
    // No document folder found for app
    return nil;
}

- (NSString *)fileWithExtension:(NSString*)dir :(NSString *)extension {
    NSLog(@"Scanning: %@", dir);
    
    // NSMutableOrderedSet *contents = [[NSMutableOrderedSet alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if (dir && ([fm fileExistsAtPath:dir isDirectory:&isDir] && isDir)) {
        if (![dir hasSuffix:@"/"]) {
            dir = [dir stringByAppendingString:@"/"];
        }
        
        NSDirectoryEnumerator *de = [fm enumeratorAtPath:dir];
        NSString *f;
        NSString *fqn;
        while ((f = [de nextObject])) {
            fqn = [dir stringByAppendingString:f];
            if ([[fqn lastPathComponent] hasSuffix:extension]) {
                return fqn;
            }
            if ([fm fileExistsAtPath:fqn isDirectory:&isDir] && isDir) {
                fqn = [fqn stringByAppendingString:@"/"];
            }
        }
    }
    else {
        printf("%s must be directory and must exist\n", [dir UTF8String]);
    }
    
    return nil;
}


- (NSString *)fullPath {
    if (self.itemType == MFLAppItem) {
        NSString* path = [self.parent fullPath];
        // Example:
        //~/Library/Developer/CoreSimulator/Devices/7B653CE4-A57A-4D5A-B4BA-4DC212E9285D/data/Containers/Bundle/Application/F664257E-95A0-4A98-BB70-52F5927ADB41/Beepngo.app
        

        return [NSString stringWithFormat:@"%@/data/Containers/Bundle/Application/%@", path, self.relativePath];
    } else if (self.parent) {
        return [[self.parent fullPath] stringByAppendingPathComponent:self.relativePath];
    }
    
    return self.relativePath;
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
        switch (self.itemType) {
            case MFLRootItem: {
                return @"root";
                break;
            }
            case MFLSimulatorItem: {
                return [self.simInfo valueForKey:@"name"];
                break;
            }
            case MFLAppItem: {
                //return [self.simInfo valueForKey:APP_NAME_KEY];
                return [self.fullAppPath lastPathComponent];
            }
                
        }
        
        //return @"Error";
    }
    
    return [self.path lastPathComponent];
}

- (NSString*) documentsFolder {
    NSAssert1(self.itemType == MFLAppItem, @"Expected application but got: %ld", self.itemType);
    // AppDir: /Users/chris/Library/Developer/CoreSimulator/Devices/7B653CE4-A57A-4D5A-B4BA-4DC212E9285D
    // DocDir: /data/Containers/Data/Application/F350ED17-A156-4FA5-B990-FBEB6D0CD9D2/Documents
    // PFile:  /Beepngo.sqlite
    //NSString* documentsPath =  [NSString stringWithFormat:@"%@/data/Containers/Data/Application/%@/Documents", self.parent.fullPath, self.path];
    NSString* documentsPath = [self findDocumentForApplication:self.appPackage atPath:self.parent.fullPath];
    
    return documentsPath;
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
