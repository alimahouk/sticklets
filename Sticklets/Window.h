//
//  Window.h
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Cocoa;

@class TextView;
@class Titlebar;

@interface Window : NSWindow <NSTextViewDelegate>
{
        NSScrollView *scrollView;
        NSTrackingArea *titlebarTrackingArea;
        Titlebar *titlebar;
        BOOL shouldSaveWindow;
}

@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *modified;
@property (strong, nonatomic) NSString *noteID;
@property (strong, nonatomic) TextView *textView;

- (void)closeWindow;
- (void)shrink;

@end
