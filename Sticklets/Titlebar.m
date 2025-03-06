//
//  Titlebar.m
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "Titlebar.h"

@implementation Titlebar

- (instancetype)initWithFrame:(NSRect)frame
{
        self = [super initWithFrame:frame];
        
        if ( self ) {
                _closeButton       = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSTexturedBackgroundWindowMask];
                _closeButton.frame = NSMakeRect(8, 0, _closeButton.bounds.size.width, _closeButton.bounds.size.height);
                
                _buttonArea        = [[NSTrackingArea alloc] initWithRect:_closeButton.frame
                                                                  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                                    owner:self
                                                                 userInfo:nil];
                
                self.autoresizingMask = NSViewWidthSizable;
                
                [self addSubview:_closeButton];
                [self addTrackingArea:_buttonArea];
        }
        
        return self;
}

- (BOOL)mouseDownCanMoveWindow
{
        return YES;
}

- (BOOL)_mouseInGroup:(id)sender
{
        return [self mouse:[self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil] inRect:_buttonArea.rect];
}

- (void)mouseEntered:(NSEvent *)event
{
        @try {
                if ( event.trackingArea == _buttonArea )
                        [_closeButton setNeedsDisplay:YES];
        } @catch ( NSException *e ) {
                
        }
}

- (void)mouseExited:(NSEvent *)event
{
        @try {
                if ( event.trackingArea == _buttonArea )
                        [_closeButton setNeedsDisplay:YES];
        } @catch ( NSException *e ) {
                
        }
}

@end
