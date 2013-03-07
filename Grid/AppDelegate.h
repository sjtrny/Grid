//
//  AppDelegate.h
//  Grid
//
//  Created by Steve on 3/03/13.
//
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GameView *view;

@end
