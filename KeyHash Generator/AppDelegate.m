//
//  AppDelegate.m
//  KeyHash Generator
//
//  Created by Shahar Barsheshet on 4/30/14.
//  Copyright (c) 2014 PeleBit. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    // Insert code here to initialize your application
    _dnd.delegate = self;
}

/**
 *  close the app
 *
 *  @param theApplication - this Application
 *
 *  @return true to close the app on last window closed
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
    return YES;
}

/**
 *  handle the drag and drop operation
 *
 *  @param url <#url description#>
 */
- (void)handleDnD:(NSString*)url
{
    NSString* newStr = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    _textFieldkeystorePath.stringValue = newStr;
}

- (IBAction)getKey:(id)sender
{

    // if there are missing fields,
    // notify the user.
    if (_textFieldAlias.stringValue == nil || _textFieldAlias.stringValue.length == 0 || _textFieldkeystorePath.stringValue == nil || _textFieldkeystorePath.stringValue.length == 0 || _textFieldPass.stringValue == nil || _textFieldPass.stringValue.length == 0) {

        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Missing fields dude..."];
        [alert runModal];

        return;
    }

    // all good, run the command
    NSString* response = runCommand([NSString stringWithFormat:@"keytool -exportcert -alias %@ -storepass %@ -keystore %@ | openssl  sha1 -binary | openssl base64", _textFieldAlias.stringValue, _textFieldPass.stringValue, _textFieldkeystorePath.stringValue]);
    BOOL copiedFromClipboard = false;
    if (response != nil) {
        NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
        copiedFromClipboard = [pasteboard setString:response forType:NSStringPboardType];
    }
    if (copiedFromClipboard) {
        _textFieldHash.stringValue = [NSString stringWithFormat:@"%@\n\n Copied to clipboard!", response];
    }
    else {
        _textFieldHash.stringValue = response;
    }
}
/**
 *  open the donation webview
 *
 *  @param sender button called
 */
- (IBAction)openDonate:(id)sender
{
    NSString* url = @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=shahar2k5@gmail.com&lc=IL&item_name=KeyHashDonation_OSX&currency_code=USD&bn=PP-DonationsBF";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

/**
 *  run a command in bash
 *
 *  @param commandToRun - the command to execute
 *
 *  @return - NSString - output from the console
 */
NSString* runCommand(NSString* commandToRun)
{
    NSTask* task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray* arguments = [NSArray arrayWithObjects:
                                      @"-c",
                                  [NSString stringWithFormat:@"%@", commandToRun],
                                  nil];
    [task setArguments:arguments];

    NSPipe* pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSFileHandle* file;
    file = [pipe fileHandleForReading];

    [task launch];

    NSData* data;
    data = [file readDataToEndOfFile];

    NSString* output;
    output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
/**
 *  open my website
 *
 *  @param sender - button
 */
- (IBAction)openWebsite:(id)sender
{
    NSString* url = @"http://bytesizebit.com";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

/**
 *  set the default values for the key and alias
 *
 *  @param sender - button
 */
- (IBAction)setDefaults:(id)sender
{
    [self.textFieldAlias setStringValue:@"androiddebugkey"];
    [self.textFieldPass setStringValue:@"android"];
}

@end
