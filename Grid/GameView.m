//
//  GameView.m
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

#import "GameView.h"
#import "CarbonKeyEvents.h"
#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

@implementation GameView

- (void)awakeFromNib
{
    mTime1 = clock();
    
    mPieces = [[Pieces alloc] init];
    mBoard = [[Board alloc] initWithPieces:mPieces];
    mGame = [[Game alloc] initWithBoard:mBoard Pieces:mPieces];
}

- (void)prepareOpenGL
{
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    @autoreleasepool {
    CVReturn result = [(__bridge GameView*)displayLinkContext getFrameForTime:outputTime];
    return result;
    }
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{    
    // Draw
    [self drawView];
    
    // Update
    [self updateView];
    
    return kCVReturnSuccess;
}

/*
 Draws a filled rectangle
 */
- (void)drawRectangle:(CGRect)rectangle
{
    glBegin(GL_POLYGON);
    glVertex2i(rectangle.origin.x, rectangle.origin.y);
    glVertex2i(rectangle.origin.x + rectangle.size.width, rectangle.origin.y);
    glVertex2i(rectangle.origin.x + rectangle.size.width, rectangle.origin.y + rectangle.size.height);
    glVertex2i(rectangle.origin.x, rectangle.origin.y + rectangle.size.height);
    glEnd();
}

- (void)drawBoardBackground
{
    glColor3f(1.0, 1.0, 1.0);
    
    CGRect board = CGRectMake(0, 0, BLOCK_SIZE * BOARD_WIDTH, BLOCK_SIZE * BOARD_HEIGHT);
    [self drawRectangle:board];
}

- (void)drawDroppedPieces
{
    glColor3f(1.0, 0.0, 0.0);
	for (int i = 0; i < BOARD_WIDTH; i++)
	{
		for (int j = 0; j < BOARD_HEIGHT; j++)
		{
			// Check if the block is filled, if so, draw it
			if (![mBoard isFreeBlockAtX:i andY:j])
            {
                [self drawRectangle:CGRectMake(i * BLOCK_SIZE, j * BLOCK_SIZE, BLOCK_SIZE - 1, BLOCK_SIZE - 1)];
            }
		}
	}
}

- (void)drawPieceAtX:(int)x andY:(int)y withPiece:(int)piece andRotation:(int)rotation
{
    // Travel the matrix of blocks of the piece and draw the blocks that are filled
	for (int i = 0; i < PIECE_BLOCKS; i++)
	{
		for (int j = 0; j < PIECE_BLOCKS; j++)
		{
			// Get the type of the block and draw it with the correct color
			switch ([mPieces getBlockTypeForPiece:piece withRotation:rotation atLocationWithX:j andY:i])
			{
				case 1: glColor3f(0.0, 1.0, 0.0);; break;	// For each block of the piece except the pivot
				case 2: glColor3f(0.0, 0.0, 1.0);; break;	// For the pivot
			}
			
			if ([mPieces getBlockTypeForPiece:piece withRotation:rotation atLocationWithX:j andY:i] != 0)
            {
                [self drawRectangle:CGRectMake(x *BLOCK_SIZE + i * BLOCK_SIZE,y * BLOCK_SIZE + j * BLOCK_SIZE, BLOCK_SIZE - 1, BLOCK_SIZE - 1)];
            }
		}
	}
}

- (void) drawView
{
	[[self openGLContext] makeCurrentContext];
    
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
    
    // Set viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glLoadIdentity();
    glOrtho(0, self.frame.size.width, self.frame.size.height, 0, -1, 1);
    
    // Clear buffer
    glClearColor(0, 0, 0, 0);
    
    glClear(GL_COLOR_BUFFER_BIT);
        
    // Draw board background
    [self drawBoardBackground];
    [self drawDroppedPieces];
    
    // Draw the current playing piece
	[self drawPieceAtX:mGame.mPosX andY:mGame.mPosY withPiece:mGame.mPiece andRotation:mGame.mRotation];
    
    // Draw the next piece
	[self drawPieceAtX:mGame.mNextPosX andY:mGame.mNextPosY withPiece:mGame.mNextPiece andRotation:mGame.mNextRotation];
    
    // Update screen
    glFlush();
	CGLFlushDrawable([[self openGLContext] CGLContextObj]);
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void)updateView
{
    // Handle input
    if (keyboardState[kVK_RightArrow])
    {
        if ([mBoard isPossibleMovementAtX:mGame.mPosX + 1 andY:mGame.mPosY withPiece:mGame.mPiece andRotation:mGame.mRotation])
            mGame.mPosX++;
    }
    if (keyboardState[kVK_LeftArrow])
    {
        if ([mBoard isPossibleMovementAtX:mGame.mPosX - 1 andY:mGame.mPosY withPiece:mGame.mPiece andRotation:mGame.mRotation])
            mGame.mPosX--;
    }
    if (keyboardState[kVK_DownArrow])
    {
        if ([mBoard isPossibleMovementAtX:mGame.mPosX andY:mGame.mPosY + 1 withPiece:mGame.mPiece andRotation:mGame.mRotation])
            mGame.mPosY++;
    }
    if (keyboardState[kVK_Space])
    {
        // Check collision from up to down
        while ([mBoard isPossibleMovementAtX:mGame.mPosX andY:mGame.mPosY withPiece:mGame.mPiece andRotation:mGame.mRotation])
        {
            mGame.mPosY++;
        }
        
        [mBoard storePieceAtX:mGame.mPosX andY:mGame.mPosY - 1 withPiece:mGame.mPiece andRotation:mGame.mRotation];
        
        [mBoard deletePossibleLines];
        
        if ([mBoard isGameOver])
        {
            [[NSApplication sharedApplication] terminate:nil];
        }
        
        [mGame createNewPiece];
        
    }
    if (keyboardState[kVK_UpArrow])
    {
        if ([mBoard isPossibleMovementAtX:mGame.mPosX andY:mGame.mPosY withPiece:mGame.mPiece andRotation:(mGame.mRotation + 1) % 4])
            mGame.mRotation = (mGame.mRotation + 1) % 4;

    }

    
    // Handle vertical movement
    
    unsigned long mTime2 = clock();
    
    if ((mTime2 - mTime1) > WAIT_TIME)
    {
        if ([mBoard isPossibleMovementAtX:mGame.mPosX andY:mGame.mPosY+1 withPiece:mGame.mPiece andRotation:mGame.mRotation])
        {
            mGame.mPosY++;
        }
        else
        {
            [mBoard storePieceAtX:mGame.mPosX andY:mGame.mPosY withPiece:mGame.mPiece andRotation: mGame.mRotation];
            
            [mBoard deletePossibleLines];
            
            if ([mBoard isGameOver])
            {
                       [[NSApplication sharedApplication] terminate:nil];
            }
            
            [mGame createNewPiece];
        }
        
        mTime1 = clock();
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    if([theEvent keyCode] == kVK_Escape)
       [[NSApplication sharedApplication] terminate:nil];
    else
    {
        keyboardState[[theEvent keyCode]] = TRUE;
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    keyboardState[[theEvent keyCode]] = FALSE;
}

- (void) reshape
{
    // Anti flickering magic
	[[self openGLContext] update];
}

- (void)update
{
    
}


-(BOOL)acceptsFirstResponder { return YES; }

@end
