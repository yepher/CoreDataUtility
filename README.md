# CoreDataPro - CoreDataUtility

You can find relases here: [releases]

[releases]: https://github.com/yepher/CoreDataUtility/releases  "Applicaion Releases"

CoreDataPro lets you view explore your datamodel and view data that your application has stored. I am looking forward to your feedback and help making this project more powerful and useful.

## Background

CoreDataPro is an OSX application developed by mFluent LLC and is meant to simplify the
development and debugging of CoreData enabled applications.
    
CoreDataPro is an application that was going to be sold in App Store but due to Apple's 
Sandbox limitations it would need to be changed in such ways that would make it almost 
useless.

This project was an internal tool. It was created because of the lack of good tools that 
makes it easy to debug and develop applications that use Core Data. 

## Command Line Usage


### Help

At command line:

````
$ *./CoreDataPro.app/Contents/MacOS/CoreDataPro --help
`````


Output

`````
--model FILE 		 (Required) Specify the location of the model file
--store FILE 		 (Required) Specify the location of the persistent store file
--storeType TYPE 		 (Required) Specify the type of the persistent store file, types include: SQLite, XML, Binary

`````


## XCode 6 and iOS Simulator project files

With the release of XCode 6 the simulator changes the name of the persistence storage location. Until there is a deterministic way to locate the files the project file is broken for the simulator. Here is a work around, that is probably better than the original way:

Add this code to your iOS application:

### Objective C
`````
#if !(TARGET_OS_EMBEDDED)  // This will work for Mac or Simulator but excludes physical iOS devices
- (void) createCoreDataDebugProjectWithType: (NSNumber*) storeFormat storeUrl:(NSString*) storeURL modelFilePath:(NSString*) modelFilePath {
    NSDictionary* project = @{
                              @"storeFilePath": storeURL,
                              @"storeFormat" : storeFormat,
                              @"modelFilePath": modelFilePath,
                              @"v" : @(1)
                              };
    
    NSString* projectFile = [NSString stringWithFormat:@"/tmp/%@.cdp", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]];
    
    [project writeToFile:projectFile atomically:YES];
    
}
#endif
`````

### Swift

`````
#if !(TARGET_OS_EMBEDDED)
    func createCoreDataDebugProjectWithType(storeFormat: NSNumber, storeURL: String, modelFilePath: String) {
        
        var project:NSDictionary = [
            "storeFilePath": storeURL,
            "storeFormat" : storeFormat,
            "modelFilePath": modelFilePath,
            "v" : "1"
        ]
        
        var projectFile = "/tmp/\(NSBundle.mainBundle().infoDictionary![kCFBundleNameKey]!).cdp"
        
        project.writeToFile(projectFile, atomically: true)
    }
    
#endif
`````

Now call that code where you initialize your CoreData persistent store. 

Something like this:


### Objective C
`````
#if !(TARGET_OS_EMBEDDED)  // This will work for Mac or Simulator but excludes physical iOS devices
#ifdef DEBUG
    // @(1) is NSSQLiteStoreType
    [self createCoreDataDebugProjectWithType:@(1) storeUrl:[storeURL absoluteString] modelFilePath:[modelUrl absoluteString]];
#endif
#endif
`````

### Swift

`````

#if !(TARGET_OS_EMBEDDED)  // This will work for Mac or Simulator but excludes physical iOS devices
#if DEBUG
	// @(1) is NSSQLiteStoreType
	createCoreDataDebugProjectWithType(1, storeURL: persistentStore!.URL!.absoluteString!, modelFilePath: modelUrl.absoluteString!)
#endif
#endif

`````

Now you can just open the /tmp/YourAppName.cdp file and it will open CoreDataUtility with your app's data loaded.


This is CoreDataUtilities storage types:
`````
typedef NS_ENUM(NSInteger, MFL_StoreTypes) {
    MFL_SQLiteStoreType = 1,
    MFL_XMLStoreType = 2,
    MFL_BinaryStoreType = 3,
    MFL_InMemoryStoreType = 4,
};

````

If you Mac app is sandboxed you may need to create a debug entitilment file and add the following for your project file to get created

`````
<key>com.apple.security.temporary-exception.files.absolute-path.read-write</key>
	<array>
		<string>/tmp/</string>
	</array>
`````




## GUI Getting Started


1. To get started using the CoreDataPro. Download the latest binary from here: https://github.com/yepher/CoreDataUtility/wiki (It is better to build for yourself from the latest source code)
     
2. Unzip that into your Applications directory and run it.

3. Select File->New Project

4. Run the app that you want to debug

5. In CoreDataPro Pick File, OSX, or IOS (Simulator only) tab

6. Select your APP or .MOM file

7. Select your persistence file (this is stored where ever you told the app to store it)

8. Explore the features of CoreDataPro


## Project Goals

Make it very easy to view/debug core data persistence.


## View Your Data from Evernote


For demonstration purposes I picked a free app (Evernote) from App Store that uses CoreData to store its data. Viewing your apps data will be done in the same way.

To view EverNotes data do the following:

1. Launch Evernote on your Mac
2. Launch CoreDataPro
3. Select Menu->File->New Project
3. Select the "OSX Process" tab
   * Or you could use file tab and browse to "/Applications/Evernote.app/Contents/Resources/LocalNoteStore.mom"
4. Select "Evernote" from the drop down list
5. Select "Evernote.app LocalNoteStore.mom" from the drop down list.
6. Now find Evernote's persistence file
7. Select "Application Support" button and browse up one directory level
8. Browse to "~/Library/Containers/com.evernote.Evernote/Data/Library/Application%20Support/Evernote/accounts/Evernote/YOUR_USERNAME/Evernote.sql"
9. Make sure "SQL" persistence Format is selected
10. Select Open
11. Browse your Evernote data

![Selecting A File](https://raw.github.com/yepher/CoreDataUtility/develop/screenShots/newProj_osxApp.png)
![Evernote Data](https://raw.github.com/yepher/CoreDataUtility/develop/screenShots/EverNote.png)



## Similar Tools


CoreDataEditor is a good CoreData utility.
    https://github.com/ChristianKienle/Core-Data-Editor
    
This tool looks really cool but I never quite figured it out:
    http://pmougin.wordpress.com/2010/04/11/core-data-browser-app/

This tool looks good:
    http://corner.squareup.com/2012/08/ponydebugger-remote-debugging.html


## TODO

*** This is a very early work in progress so there is still a lot to do. ***

- Enable changing of core data persistence files
- Enable directly viewing/modifying CoreData files running on physical device that is on same lan
- Automatically track iOS app directory and persistence files


