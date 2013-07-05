//
//  ViewController.h
//  RaceToSpace
//
//  Created by Erick Bennett on 6/26/13.
//  Copyright (c) 2013 Erick Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DicePlus/DicePlus.h>
#import "Player.h"


@interface ViewController : UIViewController <DPDiceManagerDelegate, UIAlertViewDelegate>
{
    DPDiceManager* diceManager;
    DPDie* availableDie;
    DPDie* connectedDie;
}
@property (weak, nonatomic) IBOutlet UILabel *player1Score;
@property (weak, nonatomic) IBOutlet UILabel *player2Score;
@property (weak, nonatomic) IBOutlet UIImageView *spaceBackground;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (nonatomic, retain) NSArray *players;
@property (nonatomic, retain) Player *currentPlayer;
@property (weak, nonatomic) IBOutlet UIButton *play;

@end
