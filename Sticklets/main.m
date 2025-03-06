//
//  main.m
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Cocoa;

#import "AppDelegate.h"

int main(int argc, const char *argv[])
{
        @autoreleasepool {
                AppDelegate *applicationDelegate;
                NSApplication *application;
                NSArray *tl;
                
                application = NSApplication.sharedApplication;
                
                [NSBundle.mainBundle loadNibNamed:@"MainMenu" owner:application topLevelObjects:&tl];
                
                 applicationDelegate = [AppDelegate new];
                
                [application setDelegate:applicationDelegate];
                [application run];
        }
        
        return 0;
}
