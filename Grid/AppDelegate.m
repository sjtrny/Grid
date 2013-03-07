//
//  AppDelegate.m
//  Grid
//
//  Created by Steve on 3/03/13.
//
//

#import "AppDelegate.h"
#import "GameController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(void) specialWindowDidResize: (NSNotification*) n
{
    // Code that was unhappy when executing on a non-main thread
}


- (void)windowWillStartLiveResize:(NSNotification *)notification
{
}

- (void)windowDidEndLiveResize:(NSNotification *)notification
{
    
}

@end
