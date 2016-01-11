//
//  AppDelegate.h
//  KeyHash Generator
//
//  Created by Shahar Barsheshet on 4/30/14.
//  Copyright (c) 2014 PeleBit. All rights reserved.
//

#import "DragDropImageView.h"
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, DragAndDropDelegate> {
    //highlight the drop zone
    BOOL highlight;
}

@property (weak) IBOutlet NSTextField* textFieldAlias;
@property (weak) IBOutlet NSTextField* textFieldPass;
@property (weak) IBOutlet NSButton* setDefaults;
@property (weak) IBOutlet NSTextField* textFieldkeystorePath;
@property (weak) IBOutlet NSTextField* textFieldHash;
@property (weak) IBOutlet NSButton* buttonGetKey;
@property (weak) IBOutlet DragDropImageView* dnd;
@property (weak) IBOutlet NSButton* donate;

@end
