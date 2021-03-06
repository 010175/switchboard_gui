//
//  Switchboard_GUIAppDelegate.h
//  Switchboard GUI
//
//  Created by guillaume on 27/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Switchboard_GUIAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextView *textView;
    IBOutlet NSButton   *resetButton;
    IBOutlet NSTextField *webConsoleURLTextField;
    IBOutlet NSTextField *locationTextField;
    IBOutlet NSTextField *startupProcessTextField;
    
    NSTask *switchboardTask;
    
    NSPipe *thePipe;
    NSFileHandle *pipeOutputFileHandle;
    
    BOOL    switchBoardCanQuit;
    
  
    
@private
    NSWindow *window;
    
}

-(IBAction)resetButtonAction:(id)sender;
-(IBAction)locationTextFieldAction:(id)sender;
-(IBAction)webConsoleURLTextFieldAction:(id)sender;
-(IBAction)startupProcessTextFieldAction:(id)sender;

-(void)savePreferences;

@property (assign) IBOutlet NSWindow    *window;
@property (assign) IBOutlet NSTextView  *textView;
@property (assign) IBOutlet NSButton    *resetButton;
@property (assign) IBOutlet NSTextField *webConsoleURLTextField;
@property (assign) IBOutlet NSTextField *locationTextField;
@property (assign) IBOutlet NSTextField *startupProcessTextField;
@end
