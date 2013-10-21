CoreDataPro - CoreDataUtility
===============

CoreDataPro lets you view explore your datamodel and view data that your application has stored. I am looking forward to your feedback and help making this project more powerful and useful.

Background
===============

CoreDataPro is an OSX application developed by mFluent LLC and is meant to simplify the
development and debugging of CoreData enabled applications.
    
CoreDataPro is an application that was going to be sold in App Store but due to Apple's 
Sandbox limitations it would need to be changed in such ways that would make it almost 
useless.

This project was an internal tool. It was created because of the lack of good tools that 
makes it easy to debug and develop applications that use Core Data. 


View Your Data from Evernote
========================

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



Getting Started
===============

1. To get started using the CoreDataPro. Download the binary from here: (It is best to build from the source code)
     https://github.com/downloads/yepher/CoreDataUtility/CoreDataPro.app.zip
     
2. Unzip that into your Applications directory and run it.

3. Select File->New Project

4. Run the app that you want to debug

5. In CoreDataPro Pick File, OSX, or IOS (Simulator only) tab

6. Select your APP or .MOM file

7. Select your persistence file (this is stored where ever you told the app to store it)

8. Explore the features of CoreDataPro


Project Goals
===============

Make it very easy to view/debug core data persistence.


Similar Tools
===============

In many ways CoreDataUtility is similar to CoreDataEditor.
    http://itunes.apple.com/app/core-data-editor/id403025957?mt=12&ign-mpt=uo%3D4
    
This tool looks really cool but I never quite figured it out:
    http://pmougin.wordpress.com/2010/04/11/core-data-browser-app/

This tool looks good:
    http://corner.squareup.com/2012/08/ponydebugger-remote-debugging.html

TODO
===============
*** This is a very early work in progress so there is still a lot to do. ***

- Enable changing of core data persistence files
- Enable directly viewing/modifying CoreData files running on physical device that is on same lan
- Automatically track iOS app directory and persistence files


