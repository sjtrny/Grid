//
//  GameView.h
//  Tetris
//
//  Created by Stephen Tierney on 1/03/13.
//  Copyright (c) 2013 Stephen Tierney. All rights reserved.
//
//  Licensed under the WTFPL, Version 2.0 (the "License")
//  You may obtain a copy of the License at
//
//  http://www.wtfpl.net/about/
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import "Game.h"
#import "NSMutableArray+QueueAdditions.h"
#import "CarbonKeyEvents.h" 

@interface GameView : NSOpenGLView
{
    CVDisplayLinkRef displayLink; //display link for managing rendering thread

    long lastVerticalUpdate;
    long lastXMove;
    long lastSpin;
    long lastDrop;
    
    Pieces *mPieces;
    Board *mBoard;
    Game *mGame;
    
    BOOL keyboardState[NUMKEYS];
}

@end
