//
//  TextView.m
//  Sticklets
//
//  Created by Ali Mahouk on 12/10/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "TextView.h"

@implementation TextView


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
        NSPasteboard *pasteboard;
        
        pasteboard = [sender draggingPasteboard];
        
        if ( [pasteboard.types containsObject:NSFilenamesPboardType] ) {
                NSArray *filenames;
                
                filenames = [pasteboard propertyListForType:NSFilenamesPboardType];
                
                for ( NSString *filename in filenames ) {
                        NSError *error;
                        NSImage *image;
                        NSString *fileContents;
                        NSStringEncoding encoding;
                        
                        fileContents = [NSString stringWithContentsOfFile:filename usedEncoding:&encoding error:&error];
                        
                        if ( error ) {
                                NSAttributedString *attributedString;
                                NSTextAttachment *attachment;
                                NSTextAttachmentCell *attachmentCell;
                                
                                image          = [[NSImage alloc] initWithContentsOfFile:filename];
                                attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:image];
                                attachment     = [NSTextAttachment new];
                                
                                [attachment setAttachmentCell:attachmentCell];
                                
                                attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
                                
                                [self.textStorage insertAttributedString:attributedString atIndex:self.selectedRange.location];
                        } else {
                                [self setString:fileContents];
                        }
                }
                
        }
        
        else if ( [pasteboard.types containsObject:NSPasteboardTypeString] ) {
                NSString *draggedString = [pasteboard stringForType:NSPasteboardTypeString];
                
                [self setString:draggedString];
        }
        
        if ( [self.delegate respondsToSelector:@selector(textDidChange:)] )
                [self.delegate textDidChange:[NSNotification notificationWithName:@"NSNotificationTextViewDidDrop" object:self]];
        
        [self setNeedsDisplay:YES];
        
        return YES;
}

- (NSDragOperation)draggingEntered:(id)sender
{
        NSPasteboard *pasteboard;
        NSDragOperation dragOperation;
        
        pasteboard    = [sender draggingPasteboard];
        dragOperation = [sender draggingSourceOperationMask];
        
        if ( [pasteboard.types containsObject:NSFilenamesPboardType] )
                if ( dragOperation & NSDragOperationCopy )
                        return NSDragOperationCopy;
        
        if ( [pasteboard.types containsObject:NSPasteboardTypeString] )
                if ( dragOperation & NSDragOperationCopy )
                        return NSDragOperationCopy;
        
        return NSDragOperationNone;
        
}


@end
