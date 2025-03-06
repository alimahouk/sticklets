//
//  Window.m
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "Window.h"

#import "AppDelegate.h"
#import "TextView.h"
#import "Titlebar.h"

@implementation Window


- (instancetype)initWithContentRect:(NSRect)contentRect
{
        return [self initWithContentRect:contentRect styleMask:0 backing:0 defer:NO];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
        self = [super initWithContentRect:contentRect styleMask:style backing:NSBackingStoreBuffered defer:NO];
        
        if ( self ) {
                NSArray *noteColors;
                
                _created   = [NSDate date];
                _modified  = [NSDate date];
                noteColors = @[[NSColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.9],
                               [NSColor colorWithRed:255/255.0 green:224/255.0 blue:224/255.0 alpha:0.9],
                               [NSColor colorWithRed:224/255.0 green:255/255.0 blue:224/255.0 alpha:0.9],
                               [NSColor colorWithRed:224/255.0 green:224/255.0 blue:255/255.0 alpha:0.9],
                               [NSColor colorWithRed:255/255.0 green:255/255.0 blue:224/255.0 alpha:0.9]];
                _noteID    = [NSUUID.UUID UUIDString];
                
                scrollView                       = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 20, self.frame.size.width - 40, self.frame.size.height - 40)];
                scrollView.autoresizingMask      = NSViewHeightSizable | NSViewWidthSizable;
                scrollView.borderType            = NSNoBorder;
                scrollView.drawsBackground       = NO;
                scrollView.hasHorizontalScroller = NO;
                scrollView.hasVerticalScroller   = YES;
                
                shouldSaveWindow = NO;
                
                _textView                                   = [[TextView alloc] initWithFrame:scrollView.bounds];
                _textView.automaticLinkDetectionEnabled     = YES;
                _textView.autoresizingMask                  = NSViewHeightSizable | NSViewWidthSizable;
                _textView.backgroundColor                   = NSColor.clearColor;
                _textView.continuousSpellCheckingEnabled    = YES;
                _textView.delegate                          = self;
                _textView.font                              = [NSFont fontWithName:@"Avenir" size:14];
                _textView.horizontallyResizable             = NO;
                _textView.maxSize                           = NSMakeSize(FLT_MAX, FLT_MAX);
                _textView.minSize                           = NSMakeSize(0, scrollView.contentSize.height);
                _textView.textContainer.containerSize       = NSMakeSize(scrollView.contentSize.width, FLT_MAX);
                _textView.textContainer.widthTracksTextView = YES;
                _textView.verticallyResizable               = YES;
                
                scrollView.documentView = _textView;
                
                titlebar                    = [[Titlebar alloc] initWithFrame:NSMakeRect(0, self.frame.size.height - 21, self.frame.size.width, 21)];
                titlebar.closeButton.action = @selector(closeWindow);
                titlebar.hidden             = YES;
                
                titlebarTrackingArea = [[NSTrackingArea alloc] initWithRect:self.contentView.frame
                                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways
                                                                      owner:self
                                                                   userInfo:nil];
                
                [self.contentView addTrackingArea:titlebarTrackingArea];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidBecomeKeyNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
								    [self->titlebar setNeedsDisplay:YES];
                }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidResignKeyNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    [self->titlebar setNeedsDisplay:YES];
                }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowWillMoveNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    self->shouldSaveWindow = YES;
                }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidMoveNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    if ( self->shouldSaveWindow ) {
                                                                            [(AppDelegate *)NSApplication.sharedApplication.delegate save:self];
                                                                            
                                                                            self->shouldSaveWindow = NO;
                                                                    }
                }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowWillStartLiveResizeNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    self->shouldSaveWindow = YES;
                }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidEndLiveResizeNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    self->shouldSaveWindow = NO;
                                                            }];
                [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidResizeNotification
                                                                object:self
                                                                 queue:NSOperationQueue.mainQueue
                                                            usingBlock:^(NSNotification *notification){
                                                                    if ( self->titlebarTrackingArea ) {
                                                                            [self.contentView removeTrackingArea:self->titlebarTrackingArea];
                                                                            
                                                                            self->titlebarTrackingArea = nil;
                                                                    }
                                                                    
                                                                    self->titlebar.frame       = NSMakeRect(0, self.frame.size.height - 21, self.frame.size.width, 21);
                                                                    self->titlebarTrackingArea = [[NSTrackingArea alloc] initWithRect:self.contentView.frame
                                                                                                                        options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways
                                                                                                                          owner:self
                                                                                                                       userInfo:nil];
                                                                    
                                                                    if ( self->shouldSaveWindow )
                                                                            [(AppDelegate *)NSApplication.sharedApplication.delegate save:self];
                                                                    
                                                                    [self.contentView addTrackingArea:self->titlebarTrackingArea];
                }];
                
                [self.contentView addSubview:scrollView];
                [self.contentView addSubview:titlebar positioned:NSWindowAbove relativeTo:nil];
                [self makeFirstResponder:_textView];
                
                self.acceptsMouseMovedEvents   = YES;
                self.backgroundColor           = noteColors[arc4random_uniform((unsigned int)noteColors.count)];
                self.collectionBehavior        = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorTransient | NSWindowCollectionBehaviorFullScreenAuxiliary;
                self.hasShadow                 = YES;
                self.level                     = NSFloatingWindowLevel;
                self.movableByWindowBackground = YES;
                self.opaque                    = NO;
                self.styleMask                 = self.styleMask | NSResizableWindowMask;
        }
        
        return self;
}

- (BOOL)acceptsMouseMovedEvents
{
        return YES;
}

- (BOOL)canBecomeKeyWindow
{
        return YES;
}

- (BOOL)canBecomeMainWindow
{
        return YES;
}
- (BOOL)isEqual:(id)object
{
        if ( object ) {
                if ( [object isKindOfClass:Window.class] ) {
                        Window *obj;
                        
                        obj = (Window *)object;
                        
                        if ( [obj.noteID isEqualToString:_noteID] )
                                return YES;
                }
        }
        
        return NO;
}

- (void)closeWindow
{
        [NSNotificationCenter.defaultCenter removeObserver:self];
        
        if ( [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10, 12, 1}] ) {
                if ( [self respondsToSelector:@selector(setTouchBar:)] )
                        self.touchBar = nil;
                
                if ( [_textView respondsToSelector:@selector(setTouchBar:)] )
                        _textView.touchBar = nil;
        }
        
        [self close];
        [(AppDelegate *)NSApplication.sharedApplication.delegate didCloseWindow:self];
}

- (void)shrink
{
        NSTextContainer *textContainer = [_textView textContainer];
        NSLayoutManager *layoutManager = [_textView layoutManager];
        
        [layoutManager ensureLayoutForTextContainer:textContainer];
        [self setFrame:NSMakeRect(self.frame.origin.x,
                                  self.frame.origin.y,
                                  MIN(MAX(70, self.frame.size.width), [layoutManager usedRectForTextContainer:textContainer].size.width + 50),
                                  MIN(MAX(_textView.font.pointSize + 40, self.frame.size.height), [layoutManager usedRectForTextContainer:textContainer].size.height + 40))
               display:YES
               animate:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
        titlebar.hidden = NO;
}

- (void)mouseExited:(NSEvent *)theEvent
{
        titlebar.hidden = YES;
}

- (void)textDidChange:(NSNotification *)notification
{
        _modified = [NSDate date];
        
        [(AppDelegate *)NSApplication.sharedApplication.delegate save:self];
}


@end
