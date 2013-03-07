//
//  GameController.m
//  Grid
//
//  Created by Steve on 3/03/13.
//
//

#import "GameController.h"

@implementation GameController

@synthesize mPieces;
@synthesize mBoard;
@synthesize mGame;

- (id)init
{
    self = [super init];
    if (self)
    {
        mPieces = [[Pieces alloc] init];
        mBoard = [[Board alloc] initWithPieces:mPieces];
        mGame = [[Game alloc] initWithBoard:mBoard Pieces:mPieces];
    }
    
    return self;
}

@end
