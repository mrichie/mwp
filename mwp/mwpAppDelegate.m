//
//  mwpAppDelegate.m
//  mwp
//
//  Created by richie on 14-6-17.
//  Copyright (c) 2014年 richie. All rights reserved.
//

#import "mwpAppDelegate.h"

@implementation mwpAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self showStatusMenu];
    [self setUpSegmentControl];
    [self loadStoreState];
    [self setTimer];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.richie.osx.mwp" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.richie.osx.mwp"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mwp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (IBAction)showPreference:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:self];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"mwp.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)segControlClicked:(id)sender {
    NSInteger clickedSeg = [sender selectedSegment];
    NSLog(@"seg : %ld", clickedSeg);
    NSInteger clicedSegTag = [[sender cell] tagForSegment:clickedSeg];
    NSLog(@"tag : %ld", (long)clicedSegTag);
    switch (clickedSeg) {
        case 0:
            refreshTimeout = segMin;
            break;
        case 1:
            refreshTimeout = segHour;
            break;
        case 2:
            refreshTimeout = segDay;
            break;
        default:
            break;
    }
    [self storeState];
    [self setTimer];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


-(void) setUpSegmentControl{
    [_scChangeWP setSegmentCount:3];
    [_scChangeWP setLabel:@"Minute" forSegment:0];
    [_scChangeWP setLabel:@"Hour" forSegment:1];
    [_scChangeWP setLabel:@"Day" forSegment:2];
}

- (void)showStatusMenu {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    status_item = [bar statusItemWithLength:NSVariableStatusItemLength];
    [status_item setTitle:@"MWP"];
    [status_item setHighlightMode: YES];
    [status_item setMenu: status_menu];
}

- (void)storeState {
    NSLog(@"Storing state");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:refreshTimeout forKey:@"refreshTimeout"];
    [defaults synchronize];
}

- (void) loadStoreState{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    refreshTimeout = (int)[defaults integerForKey:@"refreshTimeout"];
    if(!refreshTimeout)
    {
        refreshTimeout = segMin;
        [self storeState];
    }

    switch(refreshTimeout){
        case segMin: [_scChangeWP setSelectedSegment:0]; break;
        case segHour: [_scChangeWP setSelectedSegment:1]; break;
        case segDay: [_scChangeWP setSelectedSegment:2]; break;
        default: [_scChangeWP setSelectedSegment:0];
    }

    [self setWallPaper];
}

-(void) changeWallPaper:(NSTimer *)t{
    activePaperIndex++;
    if(activePaperIndex >= totalPaper) activePaperIndex = 0;
    [self setWallPaper];
}

-(void) setTimer{

        if(!globalTimer)
                globalTimer = [NSTimer new];
        [globalTimer invalidate];
        if(refreshTimeout > 0)
            globalTimer = [NSTimer scheduledTimerWithTimeInterval: refreshTimeout
                                                           target: self
                                                         selector: @selector(changeWallPaper:)
                                                         userInfo: NULL
                                                          repeats: YES];

}

- (void) setWallPaper{

    NSString* paperPath = [[NSString alloc] initWithFormat:@"wallpaper/%d.jpg", activePaperIndex];
    
    NSLog(@"Loading %@", paperPath);
    
    
    NSString *path = [[NSBundle mainBundle] pathForImageResource:paperPath];
    NSLog(@"%@", path);
    if([[NSFileManager defaultManager] fileExistsAtPath: paperPath])
    {
        NSLog(@"exist Paper : %@", paperPath);
        [self setWallpaperImage:paperPath withOptions:@""];
    }
}

- (void)setWallpaperImage:(NSString *)filePath withOptions:(NSString *)options
{
    NSError *error = nil;
    NSURL *imageurl = [NSURL fileURLWithPath:filePath];
    NSLog(@"image URL: %@", [imageurl absoluteString]);
    
    Boolean allowClipping = ![options isEqualToString:@"*"];
    
    NSDictionary *curOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                NSColor.blackColor,
                                NSWorkspaceDesktopImageFillColorKey,
                                
                                [NSNumber numberWithBool:allowClipping],
                                NSWorkspaceDesktopImageAllowClippingKey,
                                
                                [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown],
                                NSWorkspaceDesktopImageScalingKey,
                                
                                nil];
    
	NSArray *screens = [NSScreen screens];
	for (NSScreen *curScreen in screens)
	{
        if (![[NSWorkspace sharedWorkspace] setDesktopImageURL: imageurl
                                                     forScreen: curScreen
                                                       options: curOptions
                                                         error: &error])
        {
            [NSApp presentError:error];
        }
    }
}
@end
