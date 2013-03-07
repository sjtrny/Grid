//
//  GameController.h
//  Grid
//
//  Created by Steve on 3/03/13.
//
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface GameController : NSObject

@property (strong, atomic) Pieces *mPieces;
@property (strong, atomic) Board *mBoard;
@property (strong, atomic) Game *mGame;

@end
