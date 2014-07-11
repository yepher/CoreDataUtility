//
//  MFLAppDelegate.m
//  CoreDataUtil
//
//  Created by Chris Wilson on 11/3/11.
//  Copyright (c) 2011 mFluent LLC. All rights reserved.
//

#import "MFLAppDelegate.h"
#import "MFLConstants.h"
#import "MFLMainWindowController.h"
#import "OpenFileSheetController.h"
#import "MFLCoreDataEditorProjectLoader.h"

NSString* const APPLICATIONS_DIR = @"/Applications/";

@interface MFLAppDelegate ()

@property (strong) OpenFileSheetController *openFileSheetController;

- (void) addRecentDocument: (NSURL*) recentDocumentUrl;

@end

@implementation MFLAppDelegate


- (BOOL) openFileHelper: (NSString*) filename {
    if ([filename hasSuffix:MFL_COREDATA_PROJECT_EXTENSION]) {        
        
        NSLog(@"Load Project File: [%@]", filename);
        NSDictionary* project = [NSDictionary dictionaryWithContentsOfFile:filename];
        NSString* momFilePath = project[MFL_MOM_FILE_KEY];
        NSString* dbFilePath = project[MFL_DB_FILE_KEY];
        NSNumber* persistenceFormat = project[MFL_DB_FORMAT_KEY];
        if (persistenceFormat == nil) {
            persistenceFormat = [NSNumber numberWithInt:MFL_SQLiteStoreType];
        }
        
        NSURL* momUrl = nil;
        NSURL* dbUrl = nil;
        if (momFilePath != nil) {
            momUrl = [NSURL URLWithString:momFilePath];
        }
        
        if (dbFilePath != nil) {
            dbUrl = [NSURL URLWithString:dbFilePath];
        }
        
        // if iOS, check if file exists otherwise search for it because it may have moved.
        NSError *err;
        if ([momUrl checkResourceIsReachableAndReturnError:&err] == NO) {
            // is iOS Simulator?
            NSRange pathRange = [momFilePath rangeOfString:APPLICATIONS_DIR];
            if (pathRange.location != NSNotFound) {
                // This is an iOS simpulator project
                NSLog(@"momPath: %@", momFilePath);
                NSString* applicationsPath = [self convertToIosApplicationsBasePath:momFilePath];
                NSString* relativeMomPath = [self convertToApplicationPath:momFilePath];
                NSString* relativeDBPath = [self convertToApplicationPath:dbFilePath];
                
                // Scan through UUID directories to see if any match our paths
                // Search through each UUID to find our files
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError* error;
                NSArray* contents = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:applicationsPath] includingPropertiesForKeys:@[NSURLFileResourceTypeDirectory] options:0 error:&error];
                for (NSString* content in contents) {
                    NSLog(@"Found: %@", content);
                    NSString* testMomPath = [NSString stringWithFormat:@"%@%@",content, relativeMomPath];
                    NSURL* testMomUrl = [NSURL URLWithString:testMomPath];
                    if ([testMomUrl checkResourceIsReachableAndReturnError:&err] == NO) {
                        continue;
                    }
                    
                    NSString* testDBPath = [NSString stringWithFormat:@"%@%@", content, relativeDBPath];
                    NSURL* testDBUrl = [NSURL URLWithString:testDBPath];
                    if ([testDBUrl checkResourceIsReachableAndReturnError:&err] == NO) {
                        continue;
                    }
                    
                    // Both files exist so use this path instead.
                    momFilePath = testMomPath;
                    dbFilePath = testDBPath;
                    
                    momUrl = [NSURL URLWithString:momFilePath];
                    dbUrl = [NSURL URLWithString:dbFilePath];
                    
                    // Exit for loop
                    break;
                }
            }
        }
        
        
        BOOL result = [self.mainWindowController openFiles: momUrl persistenceFile:dbUrl persistenceType:[persistenceFormat intValue]];
        
        if (result)
        {
            [self addRecentDocument:[NSURL fileURLWithPath:filename]];
            self.projectHasChanged = true;
        }
        
        return result;
        
    } else if ([filename hasSuffix:MFL_MOM_FILE_EXTENSION]) {
        NSLog(@"Load MOM File: [%@]", filename);
        //NSURL* momUrl = [NSURL fileURLWithPath:filename];
        NSDictionary* initialValue = @{MFL_MOM_FILE_KEY: filename};
        
        if (self.openFileSheetController != nil) {
            NSBeep();
            return YES;
        }
        
        self.openFileSheetController = [[OpenFileSheetController alloc] initWithWindowNibName:@"OpenFileSheetController"];
        NSDictionary *newValues = [self.openFileSheetController show:self.window: initialValue];
        self.openFileSheetController = nil;
        if (newValues[MFL_MOM_FILE_KEY] != nil && newValues[MFL_DB_FILE_KEY] != nil)
        {
            
            NSNumber* persistenceFormat = newValues[MFL_DB_FORMAT_KEY];
            if (persistenceFormat == nil) {
                persistenceFormat = [NSNumber numberWithInt:MFL_SQLiteStoreType];
            }
            
            BOOL result = [self.mainWindowController openFiles:newValues[MFL_MOM_FILE_KEY] persistenceFile:newValues[MFL_DB_FILE_KEY] persistenceType:[persistenceFormat intValue]];
            
            if (result)
            {
                [self addRecentDocument:[NSURL fileURLWithPath:filename]];
                self.projectHasChanged = true;
            }
        }
        
        return YES;
        
    } else if ([filename hasSuffix:MFL_COREDATA_EDITOR_PROJECT_EXTENSION]) {
        MFLCoreDataEditorProjectLoader* externalLoader = [[MFLCoreDataEditorProjectLoader alloc] init];
        
        NSDictionary* project = nil;
        @try {
            project = [externalLoader decodeProjectFile:filename];
        
        } @catch (NSException *exception) {
            NSLog(@"Failed to load CoreDataEditor External Project [%@]", exception);
        }

        if (project == nil) {
            NSBeep();
            return NO;
        }
        
        self.openFileSheetController = [[OpenFileSheetController alloc] initWithWindowNibName:@"OpenFileSheetController"];
        NSDictionary *newValues = [self.openFileSheetController show:self.window: project];
        self.openFileSheetController = nil;
        if (newValues[MFL_MOM_FILE_KEY] != nil && newValues[MFL_DB_FILE_KEY] != nil)
        {
            
            NSNumber* persistenceFormat = newValues[MFL_DB_FORMAT_KEY];
            if (persistenceFormat == nil) {
                persistenceFormat = [NSNumber numberWithInt:MFL_SQLiteStoreType];
            }
            
            BOOL result = [self.mainWindowController openFiles:newValues[MFL_MOM_FILE_KEY] persistenceFile:newValues[MFL_DB_FILE_KEY] persistenceType:[persistenceFormat intValue]];
            
            if (result)
            {
                [self addRecentDocument:[NSURL fileURLWithPath:filename]];
                self.projectHasChanged = true;
            }
        }
        
        return YES;
        
    } else {
        NSLog(@"Unknown file type [%@].", filename); 
        NSBeep();
        return NO;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{   
    if (self.mainWindowController == nil) {
        self.mainWindowController = [[MFLMainWindowController alloc] initWithWindowNibName:@"MFLMainWindowController"];
    }
    
    [self handleLaunchArguments:[ [NSProcessInfo processInfo] arguments] ];
    
    [self setWindow:[self.mainWindowController window]];

    // Open previously opened file
    if ([self.mainWindowController momFileUrl] == nil) {
        NSDocumentController *controller = [NSDocumentController sharedDocumentController];
        NSArray *documents = [controller recentDocumentURLs];
        
        // If there is a recent document, try to open it.
        if ([documents count] > 0)
        {
            [self openFileHelper:[documents[0] path]];
            if ([[documents[0] absoluteString] hasSuffix:MFL_COREDATA_PROJECT_EXTENSION])
            {
                self.projectHasChanged = false;
            }
        }
        else
        {
            [self newAction:aNotification];
        }
    }
}

+ (NSUInteger)indexOfArgument:(NSString *)argumentName inArguments:(NSArray *)arguments
{
    NSUInteger result = NSNotFound;
    for (NSUInteger index = 0; index < arguments.count; index ++)
    {
        NSString *argument;
        if ( [ [arguments objectAtIndex:index] isKindOfClass:[NSString class] ] )
        {
            argument = [arguments objectAtIndex:index];
        }
        
        if ( [argument isEqualToString:argumentName] )
        {
            result = index;
            break;
        }
    }
    return result;
}

+ (NSString *)getValueForArgument:(NSString *)argumentName inArguments:(NSArray *)arguments
{
    NSString *result;
    
    NSUInteger argumentIndex = [self indexOfArgument:argumentName inArguments:arguments];
    if (argumentIndex != NSNotFound)
    {
        if (argumentIndex + 1 < arguments.count)
        {
            if ( [ [arguments objectAtIndex:argumentIndex + 1] isKindOfClass:[NSString class] ] )
            {
                result = [arguments objectAtIndex:argumentIndex + 1];
            }
        }
    }
    
    return result;
}

- (void)handleLaunchArguments:(NSArray *)launchArguments
{
    NSUInteger helpIndex = [MFLAppDelegate indexOfArgument:@"--help" inArguments:launchArguments];
    if (helpIndex != NSNotFound)
    {
        NSLog(@"Command Line Usage:");
        NSLog(@"--model FILE \t\t (Required) Specify the location of the model file");
        NSLog(@"--store FILE \t\t (Required) Specify the location of the persistent store file");
        NSLog(@"--storeType TYPE \t\t (Required) Specify the type of the persistent store file, types include: SQLite, XML, Binary");
        exit(0);
    } else
    {
        NSURL *model = [NSURL URLWithString:[MFLAppDelegate getValueForArgument:@"--model" inArguments:launchArguments] ];
        NSURL *store = [NSURL URLWithString:[MFLAppDelegate getValueForArgument:@"--store" inArguments:launchArguments] ];
        MFL_StoreTypes storeFormat = 0;
        BOOL storeFormatSet = NO;

        NSString *storeFormatString = [MFLAppDelegate getValueForArgument:@"--storeType" inArguments:launchArguments];
        if (storeFormatString)
        {
            if ( [storeFormatString isEqualToString:@"SQLite"] )
            {
                storeFormat = MFL_SQLiteStoreType;
                storeFormatSet = YES;
            } else if ( [storeFormatString isEqualToString:@"XML"] )
            {
                storeFormat = MFL_XMLStoreType;
                storeFormatSet = YES;
            } else if ( [storeFormatString isEqualToString:@"Binary"] )
            {
                storeFormat = MFL_BinaryStoreType;
                storeFormatSet = YES;
            }
        }
        
        if (model && store && storeFormatSet)
        {
            BOOL result = [self.mainWindowController openFiles:model persistenceFile:store persistenceType:(NSInteger)storeFormat];
            
            if (result) {
                self.projectHasChanged = true;
            }
        }
    }
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    if (self.mainWindowController == nil) {
        self.mainWindowController = [[MFLMainWindowController alloc] initWithWindowNibName:@"MFLMainWindowController"];
    }
    
    return [self openFileHelper:filename];
    
}

- (IBAction)openAction:(id)sender
{
    NSLog(@"openAction: [%@]", sender);
    [self.window makeKeyAndOrderFront:self];
    NSArray *fileTypes = @[MFL_COREDATA_PROJECT_EXTENSION, MFL_COREDATA_PROJECT_EXTENSION_UPERCASE, MFL_COREDATA_EDITOR_PROJECT_EXTENSION];
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:fileTypes];
    
    if ([openDlg runModal] == NSOKButton)
    {
        NSString *filename = [[openDlg URLs][0] path];
        [self openFileHelper:filename];
    }
}


- (IBAction)newAction:(id)sender
{
    NSLog(@"New Action Called.");
    if (self.openFileSheetController != nil) {
        NSBeep();
    }
    
    self.openFileSheetController = [[OpenFileSheetController alloc] initWithWindowNibName:@"OpenFileSheetController"];
    NSDictionary *newValues = [self.openFileSheetController show:self.window];
    self.openFileSheetController = nil;
    if (newValues[MFL_MOM_FILE_KEY] != nil && newValues[MFL_DB_FILE_KEY] != nil)
    {
        
        NSNumber* persistenceFormat = newValues[MFL_DB_FORMAT_KEY];
        if (persistenceFormat == nil) {
            persistenceFormat = [NSNumber numberWithInt:MFL_SQLiteStoreType];
        }
        
        BOOL result = [self.mainWindowController openFiles:newValues[MFL_MOM_FILE_KEY] persistenceFile:newValues[MFL_DB_FILE_KEY] persistenceType:[persistenceFormat intValue]];

        if (result) {
            self.projectHasChanged = true;
        }
    }
}

- (IBAction)showStoreInFinder:(id)sender {
    if (self.mainWindowController == nil) {return;}
    if (self.mainWindowController.persistenceFileUrl == nil) {return; }
    
    NSArray *fileURLs = @[self.mainWindowController.persistenceFileUrl];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (IBAction)showModelInFinder:(id)sender {
    if (self.mainWindowController == nil) {return;}
    if (self.mainWindowController.momFileUrl == nil) {return; }
    
    NSArray *fileURLs = @[self.mainWindowController.momFileUrl];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (void)addRecentDocument:(NSURL*) recentDocument
{
    NSDocumentController *docController = [NSDocumentController sharedDocumentController];
    [docController noteNewRecentDocumentURL:recentDocument];
}


- (IBAction)clearRecentDocuments:(id)sender {
    NSLog(@"clearRecentDocuments: [%@]", sender);
    NSDocumentController *docController = [NSDocumentController sharedDocumentController];
    [docController clearRecentDocuments:sender];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{

}


- (void)awakeFromNib
{
    
}

- (IBAction)saveAction:(id)sender
{
    if (self.mainWindowController == nil)
    {
        return;
    }
    
    NSInteger persistenceType = [self.mainWindowController persistenceFileFormat];
    NSURL* persistenceUrl = [self.mainWindowController persistenceFileUrl];
    NSURL* momfileUrl = [self.mainWindowController momFileUrl];
    NSLog(@"Will Save [%ld]\n%@\n%@",persistenceType, momfileUrl, persistenceUrl);
    
    if (momfileUrl != nil)
    {
        NSArray *fileTypes = @[MFL_COREDATA_PROJECT_EXTENSION, MFL_COREDATA_PROJECT_EXTENSION_UPERCASE, MFL_COREDATA_EDITOR_PROJECT_EXTENSION];
        
        NSSavePanel* saveDlg = [NSSavePanel savePanel];
        [saveDlg setAllowedFileTypes:fileTypes];
        
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentURLString = [URL_FILE_BEGINNING stringByAppendingString:documents[0]];
        [saveDlg setDirectoryURL:[NSURL URLWithString:documentURLString]];
        
        if ([saveDlg runModal] == NSSaveAsOperation)
        {
            NSDictionary *stuffToSave = @{MFL_PROJECT_FILE_VERSION_KEY: @1,
                                         MFL_MOM_FILE_KEY: [momfileUrl absoluteString],
                                         MFL_DB_FORMAT_KEY: @((int)persistenceType),
                                         MFL_DB_FILE_KEY: [persistenceUrl absoluteString]};
            
            if (![stuffToSave writeToURL:[saveDlg URL] atomically:NO])
            {
                NSLog(@"Error in saving file!");
            }
            else
            {
                [self addRecentDocument:[saveDlg URL]];
            }
            self.projectHasChanged = NO;
        } else {
            NSLog(@"User Canceled Save...");
        }
    }
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (self.projectHasChanged) {
        //Promt user to save project before exiting
        NSString *question = NSLocalizedString(@"Core Data Pro project not saved. Quit without saving?", @"UnsavedProjectChanges");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"QuitDiscardsChangesText");
        NSString *quitButton = NSLocalizedString(@"Exit", @"QuitAnywayButtonText");
        NSString *saveAndExit = NSLocalizedString(@"Save and Exit", @"SaveAndExitButtonText");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"CancelButtonText");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:saveAndExit];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        switch (answer) {
            case  NSAlertFirstButtonReturn:         // Quit Anyway
                NSLog(@"NSAlertFirstButtonReturn: Quit without saving project");
                return NSTerminateNow;
                break;
            case  NSAlertSecondButtonReturn:        // Save And Exit
                NSLog(@"NSAlertSecondButtonReturn: Save project and exit");
                [self saveAction:sender];
                
                if (self.projectHasChanged) {
                    return [self applicationShouldTerminate:sender];
                } else {
                    return NSTerminateNow;
                }
                
                break;
            case  NSAlertThirdButtonReturn:         // Cancel (Don't exit app)
                NSLog(@"NSAlertThirdButtonReturn: Cancel");
                return NSTerminateCancel;
                break;
                
            default:
                NSLog(@"default");
                return NSTerminateNow;
                break;
        }
        
        
    }
    
    return NSTerminateNow;
}


- (IBAction)reportAnIssueAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/yepher/CoreDataUtility/issues"]];
}

- (NSString*) convertToIosApplicationsBasePath:(NSString*) filePath {
    NSRange pathRange = [filePath rangeOfString:APPLICATIONS_DIR];
    if (pathRange.location == NSNotFound) {
        return nil;
    }
    
    return [filePath substringToIndex:pathRange.location+pathRange.length];
}

- (NSString*) convertToApplicationPath:(NSString*) filePath {
    NSRange pathRange = [filePath rangeOfString:APPLICATIONS_DIR];
    if (pathRange.location == NSNotFound) {
        return nil;
    }
    
    NSUInteger len = ((pathRange.location+pathRange.length) +36);
    
    if ([filePath length] <= len) {
        return nil;
    }
    
    return [filePath substringFromIndex:len];
}


@end
