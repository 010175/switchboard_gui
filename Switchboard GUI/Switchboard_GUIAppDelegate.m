//
//  Switchboard_GUIAppDelegate.m
//  Switchboard GUI
//
//  Created by guillaume on 27/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Switchboard_GUIAppDelegate.h"

@implementation Switchboard_GUIAppDelegate
@synthesize window, textView, resetButton, webConsoleURLTextField, locationTextField;

- (void)startSwitchBoardTask
{
    
    thePipe = [NSPipe pipe];
    
    pipeOutputFileHandle  = [thePipe fileHandleForReading];
    [pipeOutputFileHandle readInBackgroundAndNotify];
    
    switchboardTask = [[NSTask alloc]init];
    
    NSURL *meBundleURL = [[NSBundle mainBundle] bundleURL];
    NSURL *switchboardURL = [[meBundleURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"Switchboard"];
    NSURL *plistURL =  [[meBundleURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"preferences.plist"];
    
    NSString *switchboardPath = [switchboardURL path];
    NSLog(@"path is %@",switchboardPath);
    
    [switchboardTask setLaunchPath:[switchboardPath stringByExpandingTildeInPath]];
    
    NSData *plistData = [NSData dataWithContentsOfURL:plistURL];
    NSString *error;
    NSPropertyListFormat format;
    
    NSMutableDictionary *md = (NSMutableDictionary *)[NSPropertyListSerialization
                                                      propertyListFromData:plistData
                                                      mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                      format:&format
                                                      errorDescription:&error];
    
    if(!md){
        NSLog(@"preferences read error%@",error);
        [error release];
            
        [locationTextField setStringValue:@"nowhere"];
        [webConsoleURLTextField setStringValue:@"http://www.010175.net/monolithe/"];
        [self savePreferences];
        
    } else {
        
        NSLog(@"preferences read ok");
        
        NSString *location =  [md objectForKey:@"Location"];
        NSString *webConsoleURL =  [md objectForKey:@"Web Console URL"];
        
        [locationTextField setStringValue:location];
        [webConsoleURLTextField setStringValue:webConsoleURL];
    }
    
  
    
    [switchboardTask setStandardOutput:thePipe];
    [switchboardTask setStandardError: [switchboardTask standardOutput]];
    
    // start task
    [switchboardTask launch];
    [switchboardTask release];
    
      
    
}

-(void)savePreferences
{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [locationTextField stringValue], @"Location",  [webConsoleURLTextField stringValue], @"Web Console URL", nil];        
    
    NSURL *meBundleURL = [[NSBundle mainBundle] bundleURL];
    NSURL *plistURL =  [[meBundleURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"preferences.plist"];
    
    [dict writeToURL:plistURL atomically:YES];
    
}

#pragma mark IBActions
-(IBAction)resetButtonAction:(id)sender
{
    NSLog(@"reset");
    if ([switchboardTask isRunning]){
        [switchboardTask terminate];
        [switchboardTask interrupt];
        NSLog(@"switchboard killed");
    }
}

-(IBAction)locationTextFieldAction:(id)sender
{
    NSLog(@"location changed");
    [self savePreferences];
    
}

-(IBAction)webConsoleURLTextFieldAction:(id)sender{
    
    NSLog(@"url changed");
    [self savePreferences];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    switchBoardCanQuit = NO;
    
    [window setMovableByWindowBackground:YES];
    //[window setBackgroundColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:.5]];
    // [window setAlphaValue:.9];
    [textView setFont:[NSFont fontWithName:@"Courier" size:12.0]];
    [textView setTextColor:[NSColor colorWithDeviceRed:.25 green:.50 blue:0 alpha:1]];
    [textView setBackgroundColor:[NSColor blackColor]];
    
    [self startSwitchBoardTask];
    
}

- (id)init {
    self = [super init];
    
    // notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector( switchboardEnded: ) 
                                                 name:NSTaskDidTerminateNotification 
                                               object:switchboardTask];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector( readPipe: )
                                                 name:NSFileHandleReadCompletionNotification 
                                               object:[[switchboardTask standardOutput]fileHandleForReading]];
    
    
    
    
	return self;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
    return YES;
}

- (void)switchboardEnded:(NSNotification *)aNotification {
    
    NSLog(@"switchboard ended");
    if (switchBoardCanQuit){
        if ([switchboardTask isRunning])
            [switchboardTask terminate];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSLog(@"quit");
        
    } else { // restart switchboard
        
        NSLog(@"restarting..");
        [self startSwitchBoardTask];
    }
}

-(void)readPipe: (NSNotification *)aNotification
{
    NSData *data;
    NSString *text;
    
    if( [aNotification object] != pipeOutputFileHandle )
        return;
    
    data = [[aNotification userInfo] 
            objectForKey:NSFileHandleNotificationDataItem];
    text = [[NSString alloc] initWithData:data 
                                 encoding:NSASCIIStringEncoding];
    
    [textView setString: [[textView string]stringByAppendingString :text]];
    [text release];
    
    [textView scrollRangeToVisible:NSMakeRange([[textView string] length] - 1,0)];
    
    if( data!=0 )
        [pipeOutputFileHandle readInBackgroundAndNotify];
}

- (void)applicationWillTerminate:(NSNotification *)notification{
    
    switchBoardCanQuit = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object: [[switchboardTask standardOutput] fileHandleForReading]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object: nil];
    
    if ([switchboardTask isRunning]){
        [switchboardTask terminate];
        [switchboardTask interrupt];
        NSLog(@"switchboard killed");
    }
    
    NSLog(@"switchboard gui end");
}

@end
