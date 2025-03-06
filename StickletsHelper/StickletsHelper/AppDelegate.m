//
//  AppDelegate.m
//  StickletsHelper
//
//  Created by Ali Mahouk on 12/12/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        // Check if main app is already running; if yes, do nothing and terminate helper app.
        BOOL alreadyRunning;
        BOOL isActive;
        
        alreadyRunning = NO;
        isActive       = NO;
        
        for ( NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications ) {
                if ( [app.bundleIdentifier isEqualToString:BUNDLE_IDENTIFIER] ) {
                        alreadyRunning = YES;
                        isActive       = app.isActive;
                        
                        break;
                }
        }
        
        if ( !alreadyRunning || !isActive ) {
                NSString *newPath;
                NSMutableArray *pathComponents;
                
                pathComponents = [NSMutableArray arrayWithArray:NSBundle.mainBundle.bundlePath.pathComponents];
                
                [pathComponents removeLastObject];
                [pathComponents removeLastObject];
                [pathComponents removeLastObject];
                [pathComponents addObject:@"MacOS"];
                [pathComponents addObject:@"Sticklets"];
                
                newPath = [NSString pathWithComponents:pathComponents];
                
                [NSWorkspace.sharedWorkspace launchApplication:newPath];
        }
        
        [NSDistributedNotificationCenter.defaultCenter addObserver:self
                                                          selector:@selector(killApp)
                                                              name:TERMINATE_NOTIFICATION
                                                            object:BUNDLE_IDENTIFIER];
        
        [self killApp];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
        // Insert code here to tear down your application
}

- (void)killApp
{
        [NSApp terminate:nil];
}


@end
