//
//  Game.m
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

#import "Game.h"

@implementation Game

@synthesize mPosX, mPosY, mPiece, mRotation;
@synthesize mNextPosX, mNextPosY, mNextPiece, mNextRotation;	// Kind and rotation of the next piece

- (id)initWithBoard:(Board*)board Pieces:(Pieces*)pieces
{
    self = [super init];
    if (self) {
        
        // Get the pointer to the Board and Pieces classes
        mBoard = board;
        mPieces = pieces;
        mRotation = 0;
        mNextRotation 	= 0;
        
        // Game initialization
        [self initGame];
    }
    return self;
}

/*
 Initial parameters of the game
 */
- (void)initGame
{
    // Init random numbers
	srand ((unsigned int) time(NULL));
    
	// First piece
	mPiece			= [self getRandBetween:0 and:6];
	mPosX 			= (BOARD_WIDTH / 2) + [mPieces getXInitialPosition:mPiece withRoation:mRotation];
	mPosY 			= [mPieces getYInitialPosition:mPiece withRoation:mRotation];
    
	//  Next piece
	mNextPiece 		= [self getRandBetween:0 and:6];
	mNextPosX 		= BOARD_WIDTH + 6;
	mNextPosY 		= -1;
}

- (int)getRandBetween:(int)pA and:(int)pB
{
    return rand () % (pB - pA + 1) + pA;
}

- (void)createNewPiece
{
    // The new piece
	mPiece			= mNextPiece;
	mPosX 			= (BOARD_WIDTH / 2) + [mPieces getXInitialPosition:mPiece withRoation:mRotation];
	mPosY 			= [mPieces getYInitialPosition:mPiece withRoation:mRotation];
    
	// Random next piece
	mNextPiece 		= [self getRandBetween:0 and:6];
}

@end
