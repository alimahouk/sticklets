//
//  AppDelegate.m
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import ServiceManagement;

#import "AppDelegate.h"

#import "constants.h"
#import "Note.h"
#import "TextView.h"
#import "Window.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        mainMenu        = [[NSMenu alloc] initWithTitle:@""];
        notesAreVisible = YES;
        _noteObjects    = [NSMutableArray array];
        _noteWindows    = [NSMutableArray array];
        
        [self setupMainMenu];
        [self checkIfStartAtLogin]; // Start at login.
        [self loadNotes];
        
        if ( _noteWindows.count == 0 )
                [self newNoteWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
        // Insert code here to tear down your application
}

- (IBAction)closeNoteWindow:(id)sender
{
        Window *activeWindow;
        
        activeWindow = (Window *)NSApplication.sharedApplication.keyWindow;
        
        if ( activeWindow )
                [activeWindow closeWindow];
}

- (IBAction)newNoteWindow:(id)sender
{
        Window *newNote;
        
        newNote = [[Window alloc] initWithContentRect:NSMakeRect(30, NSScreen.mainScreen.frame.size.height - 280, 250, 250)
                                            styleMask:NSWindowStyleMaskBorderless
                                              backing:NSBackingStoreBuffered
                                                defer:YES];
        
        if ( _noteWindows.count > 0 ) {
                Window *last;
                
                last = [_noteWindows lastObject];
                
                [newNote cascadeTopLeftFromPoint:NSMakePoint(last.frame.origin.x + last.frame.size.width + 10, last.frame.origin.y + last.frame.size.height)];
        }
        
        [_noteWindows addObject:newNote];
        [newNote makeKeyAndOrderFront:self];
}

- (IBAction)shrinkWindow:(id)sender
{
        Window *activeWindow;
        
        activeWindow = (Window *)NSApplication.sharedApplication.keyWindow;
        
        if ( activeWindow )
                [activeWindow shrink];
}

- (IBAction)toggleNoteVisibility:(id)sender
{
        notesAreVisible = !notesAreVisible;
        
        [self setNotesVisibility:notesAreVisible];
}

- (void)checkIfStartAtLogin
{
        NSString *value;
        BOOL startedAtLogin; // This is for the helper app.
        
        value          = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDKEY_LOGIN_START];
        startedAtLogin = NO;
        
        if ( value )
                _startAtLogin = value.boolValue;
        else
                [self saveStartAtLogin:YES];
        
        if ( _startAtLogin )
                startAtLoginMenuItem.state = NSOnState;
        else
                startAtLoginMenuItem.state = NSOffState;
        
        for ( NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications )
                if ( [app.bundleIdentifier isEqualToString:NSBundle.mainBundle.bundleIdentifier] )
                        startedAtLogin = YES;
        
        if ( startedAtLogin ) // Kill the helper app.
                [NSDistributedNotificationCenter.defaultCenter postNotificationName:TERMINATE_NOTIFICATION
                                                                             object:NSBundle.mainBundle.bundleIdentifier];
}

- (void)didCloseWindow:(Window *)window
{
        for ( int i = 0; i < _noteObjects.count; i++ ) {
                Note *note;
                NSError *error;
                NSString *noteIdentifier;
                
                note           = _noteObjects[i];
                noteIdentifier = [note valueForKey:@"identifier"];
                
                if ( [noteIdentifier isEqualToString:window.noteID] ) {
                        [self.managedObjectContext deleteObject:note];
                        [_noteObjects removeObjectAtIndex:i];
                        
                        if ( ![self.managedObjectContext save:&error] ) {
                                NSLog(@"%@: %@", error, [error localizedDescription]);
                        }
                        
                        break;
                }
        }
        
        [_noteWindows removeObject:window];
}

- (void)killApp
{
        [NSApp terminate:nil];
}

- (void)loadNotes
{
        NSArray *results;
        NSError *error;
        NSFetchRequest *fetchRequest;
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
        results      = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ( error ) {
                NSLog(@"%@", error);
        } else {
                for ( Note *note in results ) {
                        Window *newNoteWindow;
                        
                        [_noteObjects addObject:note];
                        [self newNoteWindow:nil];
                        
                        newNoteWindow                 = [_noteWindows lastObject];
                        newNoteWindow.backgroundColor = [note valueForKey:@"noteColor"];
                        newNoteWindow.created         = [note valueForKey:@"created"];
                        newNoteWindow.noteID          = [note valueForKey:@"identifier"];
                        newNoteWindow.modified        = [note valueForKey:@"modified"];
                        
                        [newNoteWindow setFrame:[[note valueForKey:@"frame"] rectValue] display:YES];
                        [newNoteWindow.textView.textStorage setAttributedString:[note valueForKey:@"text"]];
                }
        }
}

- (void)saveStartAtLogin:(BOOL)startAtLogin
{
        if ( startAtLogin ) {
                _startAtLogin              = YES;
                startAtLoginMenuItem.state = NSOnState;
                
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:NSUDKEY_LOGIN_START];
        } else {
                _startAtLogin              = NO;
                startAtLoginMenuItem.state = NSOffState;
                
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:NSUDKEY_LOGIN_START];
        }
        
        SMLoginItemSetEnabled((__bridge CFStringRef)[NSString stringWithFormat:@"%@Helper", NSBundle.mainBundle.bundleIdentifier], _startAtLogin);
}

- (void)setNotesVisibility:(BOOL)visible
{
        for ( Window *window in _noteWindows ) {
                if ( visible )
                        [window orderFront:self];
                else
                        [window orderOut:self];
        }
}

- (void)setupMainMenu
{
        NSMenuItem *aboutMenuItem;
        NSMenuItem *newNoteMenuItem;
        NSMenuItem *noteVisibilityMenuItem;
        NSMenuItem *quitMenuItem;
        NSMenuItem *shrinkMenuItem;
        NSString *appName;
        
        appName                = [NSBundle.mainBundle.infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
        aboutMenuItem          = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"About %@", appName] action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
        newNoteMenuItem        = [[NSMenuItem alloc] initWithTitle:@"New Note" action:@selector(newNoteWindow:) keyEquivalent:@"n"];
        noteVisibilityMenuItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Visibility" action:@selector(toggleNoteVisibility:) keyEquivalent:@"h"];
        startAtLoginMenuItem   = [[NSMenuItem alloc] initWithTitle:@"Start at Login" action:@selector(toggleStartAtLogin) keyEquivalent:@""];
        quitMenuItem           = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Quit %@", appName] action:@selector(killApp) keyEquivalent:@"q"];
        shrinkMenuItem         = [[NSMenuItem alloc] initWithTitle:@"Shrink Note" action:@selector(shrinkWindow:) keyEquivalent:@"s"];
        
        _statusItem       = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        _statusItem.image = [NSImage imageNamed:@"StatusItemIconTemplate"];
        
        [_statusItem setAction:@selector(statusItemClicked)];
        [mainMenu addItem:aboutMenuItem];
        [mainMenu addItem:startAtLoginMenuItem];
        [mainMenu addItem:[NSMenuItem separatorItem]];
        [mainMenu addItem:newNoteMenuItem];
        [mainMenu addItem:shrinkMenuItem];
        [mainMenu addItem:[NSMenuItem separatorItem]];
        [mainMenu addItem:noteVisibilityMenuItem];
        [mainMenu addItem:[NSMenuItem separatorItem]];
        [mainMenu addItem:quitMenuItem];
}

- (void)statusItemClicked
{
        if ( NSEvent.modifierFlags & NSAlternateKeyMask )
                [self newNoteWindow:nil];
        else
                [_statusItem popUpStatusItemMenu:mainMenu];
}

- (void)toggleStartAtLogin
{
        [self saveStartAtLogin:!_startAtLogin];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory
{
        NSURL *appSupportURL;
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "co.alimade.Sticklets" in the user's Application Support directory.
        appSupportURL = [[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        
        return [appSupportURL URLByAppendingPathComponent:@"co.alimade.Sticklets"];
}

- (NSManagedObjectModel *)managedObjectModel
{
        NSURL *modelURL;
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        if (_managedObjectModel)
                return _managedObjectModel;
        
        modelURL            = [NSBundle.mainBundle URLForResource:@"Sticklets" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
        if (_persistentStoreCoordinator)
                return _persistentStoreCoordinator;
        
        NSFileManager *fileManager;
        NSURL *appDocumentsDirectory;
        BOOL shouldFail = NO;
        NSError *error;
        NSString *failureReason;
        NSDictionary *properties;
        
        appDocumentsDirectory = [self applicationDocumentsDirectory];
        failureReason         = @"There was an error creating or loading the application's saved data.";
        fileManager           = [NSFileManager defaultManager];
        properties            = [appDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error]; // Make sure the application files directory is there.
        
        if ( properties ) {
                if ( ![properties[NSURLIsDirectoryKey] boolValue] ) {
                        failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", appDocumentsDirectory.path];
                        shouldFail    = YES;
                }
        } else if ( error.code == NSFileReadNoSuchFileError ) {
                error = nil;
                
                [fileManager createDirectoryAtPath:[appDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if ( !shouldFail &&
             !error ) {
                NSPersistentStoreCoordinator *coordinator;
                NSURL *URL;
                
                coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
                URL         = [appDocumentsDirectory URLByAppendingPathComponent:@"Sticklets.storedata"];
                
                if ( ![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:URL options:nil error:&error] ) {
                        // Replace this implementation with code to handle the error appropriately.
                        
                        /*
                         Typical reasons for an error here include:
                         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                         * The device is out of space.
                         * The store could not be migrated to the current model version.
                         Check the error message to determine what the actual problem was.
                         */
                        coordinator = nil;
                }
                
                _persistentStoreCoordinator = coordinator;
        }
        
        if ( shouldFail ||
             error ) {
                NSMutableDictionary *dict;
                
                // Report any error we got.
                dict                                   = [NSMutableDictionary dictionary];
                dict[NSLocalizedDescriptionKey]        = @"Failed to initialize the application's saved data";
                dict[NSLocalizedFailureReasonErrorKey] = failureReason;
                
                if ( error )
                        dict[NSUnderlyingErrorKey] = error;
                
                error = [NSError errorWithDomain:@"co.alimade.Sticklets" code:9999 userInfo:dict];
                
                [NSApplication.sharedApplication presentError:error];
                
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
        }
        return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
        if ( _managedObjectContext )
                return _managedObjectContext;
        
        if ( !self.persistentStoreCoordinator )
                return nil;
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (void)save:(Window *)window
{
        Note *note;
        NSEntityDescription *entity;
        NSError *error;
        
        for ( Note *n in _noteObjects ) {
                NSString *noteIdentifier;
                
                noteIdentifier = [n valueForKey:@"identifier"];
                
                if ( [noteIdentifier isEqualToString:window.noteID] ) {
                        note = n;
                        
                        break;
                }
        }
        
        if ( !note ) {
                entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
                note   = [[Note alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                
                [_noteObjects addObject:note];
        }
        
        [note setValue:window.created forKey:@"created"];
        [note setValue:[NSValue valueWithRect:window.frame] forKey:@"frame"];
        [note setValue:window.noteID forKey:@"identifier"];
        [note setValue:window.modified forKey:@"modified"];
        [note setValue:window.backgroundColor forKey:@"noteColor"];
        [note setValue:window.textView.textStorage forKey:@"text"];
        
        if ( ![self.managedObjectContext commitEditing] )
                NSLog(@"%@:%@ unable to commit editing before saving", self.class, NSStringFromSelector(_cmd));
        
        if ( self.managedObjectContext.hasChanges &&
             ![self.managedObjectContext save:&error] )
                [NSApplication.sharedApplication presentError:error];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return [self.managedObjectContext undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
        NSError *error;
        
        // Save changes in the application's managed object context before the application terminates.
        if ( !_managedObjectContext )
                return NSTerminateNow;
        
        if ( ![_managedObjectContext commitEditing] ) {
                NSLog(@"%@:%@ unable to commit editing to terminate", self.class, NSStringFromSelector(_cmd));
                return NSTerminateCancel;
        }
        
        if ( !_managedObjectContext.hasChanges )
                return NSTerminateNow;
        
        if ( ![_managedObjectContext save:&error] ) {
                
                // Customize this code block to include application-specific recovery steps.
                BOOL result = [sender presentError:error];
                
                if ( result )
                        return NSTerminateCancel;
                
                NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
                NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
                NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
                NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
                NSAlert *alert = [NSAlert new];
                
                [alert setMessageText:question];
                [alert setInformativeText:info];
                [alert addButtonWithTitle:quitButton];
                [alert addButtonWithTitle:cancelButton];
                
                NSInteger answer = [alert runModal];
                
                if ( answer == NSAlertSecondButtonReturn )
                        return NSTerminateCancel;
        }
        
        return NSTerminateNow;
}


@end
