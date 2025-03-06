//
//  AppDelegate.h
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Cocoa;

@class Note;
@class Window;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
        NSMenu *mainMenu;
        NSMenuItem *startAtLoginMenuItem;
        BOOL notesAreVisible;
}

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray<Note *> *noteObjects;
@property (strong, nonatomic) NSMutableArray<Window *> *noteWindows;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property (assign, nonatomic) BOOL startAtLogin;

- (IBAction)closeNoteWindow:(id)sender;
- (IBAction)newNoteWindow:(id)sender;
- (IBAction)shrinkWindow:(id)sender;
- (IBAction)toggleNoteVisibility:(id)sender;

- (void)didCloseWindow:(Window *)window;
- (void)save:(Window *)window;

@end

