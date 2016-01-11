/*
     File: DragDropImageView.m 
 Abstract: Custom subclass of NSImageView with support for drag and drop operations. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "DragDropImageView.h"

@implementation DragDropImageView

@synthesize delegate;

NSString* kPrivateDragUTI = @"com.yourcompany.cocoadraganddrop";

- (id)initWithCoder:(NSCoder*)coder
{
    /*------------------------------------------------------
        Init method called for Interface Builder objects
    --------------------------------------------------------*/
    self = [super initWithCoder:coder];
    if (self) {
        //register for all the image types we can display
        [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
    }
    return self;
}

#pragma mark - Destination Operations

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    //if the drag comes from a file, set the window title to the filename
    //    NSURL *fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
    //    [[self window] setTitle: fileURL!=NULL ? [fileURL absoluteString] : @"(no name)"];

    NSLog(@"_delegate draggingEnded");
    if (NSPointInRect([sender draggingLocation], self.frame)) {
        //The file was actually dropped on the view so call the performDrag manually
        [self performDragOperation:sender];
    }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{

    NSLog(@"draggingEntered");

    //highlight our drop zone
    highlight = YES;

    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    /*------------------------------------------------------
       method called whenever a drag exits our drop zone
    --------------------------------------------------------*/
    //remove highlight of the drop zone
    highlight = NO;

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
        draw method is overridden to do drop highlighing
    --------------------------------------------------------*/
    //do the usual draw operation to display the image
    [super drawRect:rect];

    if (highlight) {
        //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth:5];
        [NSBezierPath strokeRect:rect];
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    /*------------------------------------------------------
        method to determine if we can accept the drop
    --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    highlight = NO;

    [self setNeedsDisplay:YES];
    return true;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSLog(@"performDragOperation 1 handleDnD");

    /*------------------------------------------------------
        method that should handle the drop data
    --------------------------------------------------------*/
    if ([sender draggingSource] != self) {
        NSURL* fileURL;
        //if the drag comes from a file, set the window title to the filename
        fileURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
        [delegate handleDnD:fileURL.description];
    }

    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
       delegate operation to set the standard window frame
    --------------------------------------------------------*/
    //get window frame size
    NSRect ContentRect = self.window.frame;

    //set it to the image frame size
    ContentRect.size = [[self image] size];

    return [NSWindow frameRectForContentRect:ContentRect styleMask:[window styleMask]];
};

- (NSDragOperation)draggingSession:(NSDraggingSession*)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
    case NSDraggingContextOutsideApplication:
        return NSDragOperationCopy;

    //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
    case NSDraggingContextWithinApplication:
    default:
        return NSDragOperationCopy;
        break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent*)event
{
    /*------------------------------------------------------
        accept activation click as click in window
    --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard*)sender item:(NSPasteboardItem*)item provideDataForType:(NSString*)type
{
    /*------------------------------------------------------
       	method called by pasteboard to support promised 
        drag types.
    --------------------------------------------------------*/
    //sender has accepted the drag and now we need to send the data for the type we promised
    if ([type compare:NSPasteboardTypeTIFF] == NSOrderedSame) {

        //set data for TIFF type on the pasteboard as requested
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    }
    else if ([type compare:NSPasteboardTypePDF] == NSOrderedSame) {

        //set data for PDF type on the pasteboard as requested
        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
}
@end
