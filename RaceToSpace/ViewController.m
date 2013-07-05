//
//  ViewController.m
//  RaceToSpace
//
//  Created by Erick Bennett on 6/26/13.
//  Copyright (c) 2013 Erick Bennett. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "Player.h"

@interface ViewController ()

@end

#define MaxPoints 25

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Setup Player 1
    Player *player1 = [[Player alloc] initWithImage:[UIImage imageNamed:@"rocketShip1"]];
    player1.playerNumber = 1;
    UIImageView *player1ship = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 113)];
    player1ship.contentMode = UIViewContentModeCenter;
    player1ship.image = player1.shipImage;
    player1ship.center = CGPointMake(192, 928);
    player1ship.tag = player1.playerNumber;
    [self.view addSubview:player1ship];
    
    //Setup Player 2
    Player *player2 = [[Player alloc] initWithImage:[UIImage imageNamed:@"rocketShip2"]];
    player2.playerNumber = 2;
    UIImageView *player2ship = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 113)];
    player2ship.contentMode = UIViewContentModeCenter;
    player2ship.image = player2.shipImage;
    player2ship.center = CGPointMake(576, 928);
    player2ship.tag = player2.playerNumber;
    [self.view addSubview:player2ship];
    
    //Add players to a reference array.
    self.players = [NSArray arrayWithObjects:player1, player2, nil];
    
    if (connectedDie != nil) {
        return;
    }
    availableDie = nil;
    diceManager = [DPDiceManager sharedDiceManager];
    diceManager.delegate = self;
    
    //Dice+ developer key.
    uint8_t key[8] = {0x83, 0xed, 0x60, 0x0e, 0x5d, 0x31, 0x8f, 0xe7};
    [diceManager setKey:key];
    
    //Start scanning for an available Dice+.
    [diceManager startScan];
    self.status.text = @"Searching for DICE+...";
}

- (IBAction)play:(id)sender
{
    //Rest players score to 0 in case this is a replay.
    self.play.hidden = YES;
    [self setupPlayer];
}

- (void)setupPlayer
{
    if (!self.currentPlayer){
        //Its a new game, make current player, player 1.
        self.currentPlayer = [self.players objectAtIndex:0];
    } else {
            //Switch between players
            if (self.currentPlayer.playerNumber == 1){
                //Make current player, player 2.
                self.currentPlayer = [self.players objectAtIndex:1];
            } else {
                //Make current player, player 1.
                self.currentPlayer = [self.players objectAtIndex:0];
            }
        }
    self.status.text = [NSString stringWithFormat:@"Player %i's turn", self.currentPlayer.playerNumber];
    
    //Start Dice+ roll updates for current player.
    [connectedDie startRollUpdates];
}

- (void)prepareForNewGame
{
    //Set player scores to 0 and reset ships to start position.
    for (Player *p in self.players){
        p.score = 0;
        UIImageView *playerShip = (UIImageView *)[self.view viewWithTag:p.playerNumber];
        playerShip.center = CGPointMake(playerShip.center.x, 928);
    }

    //Reset some labels
    self.play.hidden = NO;
    self.player1Score.text = @"0 points";
    self.player2Score.text = @"0 points";
    self.status.text = @"Press play to begin.";
    
    //Animate background back to start position
    [UIView animateWithDuration:.25 animations:^{
        self.spaceBackground.center = CGPointMake(384, 0);
    }];
    
    //Set current player to nil so new game will start with player 1.
    self.currentPlayer = nil;
}

- (BOOL)currentPlayerIsWinner
{
    //check if current player has matched, or exceeded max points
    if (self.currentPlayer.score >= MaxPoints){
        return YES;
    }
    return NO;
}

- (void)moveCurrentPlayer:(NSInteger)rollValue
{
    //Get UIImageView for players ship and animate p the screen.
    UIImageView *playerShip = (UIImageView *)[self.view viewWithTag:self.currentPlayer.playerNumber];
    
    //Calculate appropriate distance to travel based on MaxPoints, so winner is always near top of screen.
    int offset = (1024 - rintf(1024/6))/MaxPoints;
    int distance = rollValue * offset;
    self.currentPlayer.score = self.currentPlayer.score + rollValue;

    if ([self currentPlayerIsWinner]) {
        //Current player has won. Do something.
        NSString *winnerText = [NSString stringWithFormat:@"Congratulations player %i, you are the Winner!", self.currentPlayer.playerNumber];
        UIAlertView *winnerNotify = [[UIAlertView alloc] initWithTitle:@"WINNER!!" message:winnerText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [winnerNotify show];
        self.status.text = @"We have a WINNER!";
        
        //Fly the winning ship the rest of the way off the screen.
        [UIView animateWithDuration:1 animations:^{
            playerShip.center = CGPointMake(playerShip.center.x, -200);
        }];
        return;
    } else {
        [UIView animateWithDuration:1 animations:^{
            playerShip.center = CGPointMake(playerShip.center.x, playerShip.center.y - distance);
        }];
        if (self.currentPlayer.playerNumber == 2){
            self.player2Score.text = [NSString stringWithFormat:@"%i points", self.currentPlayer.score];
            [self slideBackground:distance];
        } else {
            self.player1Score.text = [NSString stringWithFormat:@"%i points", self.currentPlayer.score];
            [self setupPlayer];
        }
    }
}

- (void)slideBackground:(NSInteger)distance
{
    //Check if background is able to scroll any further, if so scroll up distace value.
    if (self.spaceBackground.center.y + distance < 1024){
        [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.spaceBackground.center = CGPointMake(384, self.spaceBackground.center.y + distance);
        } completion:^(BOOL finished) {
            //Setup next player when animation is done.
            [self setupPlayer];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //Once cancel is pressed on the alertview, prepare for new game.
    [self prepareForNewGame];
}

- (void)die:(DPDie *)die didRoll:(DPRoll *)roll error:(NSError *)error
{
    //Roll was valid
    if (roll.flags == DPRollFlagOK) {
        //Stop roll updates just to make sure wrong player doesnt mistakenly roll Dice+.
        [connectedDie stopRollUpdates];
        //Convert roll result (1-6) to binary mask equivalent
        int mask = 1 << (roll.result-1);
        //Blink the top face green showing roll result. Dice+ uses a binary mask for determinning which face, or faces to light.
        [connectedDie startBlinkAnimationWithMask:mask priority:0 r:0 g:255 b:0 onPeriod:100 cyclePeriod:50 blinkCount:5];
        //Move player ship
        [self moveCurrentPlayer:roll.result];
        
    } else if (roll.flags == DPRollFlagTilt) {
        //Dice+ roll error
        self.status.text = @"Roll Tilted";
        //Blink dice plus faces red to indicate a roll error occured.
        [connectedDie startBlinkAnimationWithMask:63
                                         priority:1
                                                r:255
                                                g:0
                                                b:0
                                         onPeriod:100
                                      cyclePeriod:200
                                       blinkCount:4];
    } else if (roll.flags == DPRollFlagTooShort) {
        //Dice+ roll error
        self.status.text = @"Roll too short";
        //Blink dice plus faces red to indicate a roll error occured.
        [connectedDie startBlinkAnimationWithMask:63
                                         priority:1
                                                r:255
                                                g:0
                                                b:0
                                         onPeriod:100
                                      cyclePeriod:200
                                       blinkCount:4];
    }
}

#pragma mark - DPDiceManagerDelegate methods
- (void)centralManagerDidUpdateState:(CBCentralManagerState)state
{
    // See CBCentralManagerDelegate documentation for info about CBCentralManager state changes
}

- (void)diceManagerStoppedScan:(DPDiceManager *)manager
{
    //Scanning has stopped, restart scan if no available die was found.
    if (availableDie == nil) {
        [diceManager startScan];
        self.status.text = @"Searching for DICE+...";
    }
}

- (void)diceManager:(DPDiceManager *)manager didDiscoverDie:(DPDie *)die
{
    //A Dice+ die was found, not connected yet.
    availableDie = die;
    availableDie.delegate = (id)self;
    
    [diceManager stopScan];
    //Attempt to connect to available Dice+ found.
    [diceManager connectDie:availableDie];
    
    self.status.text = @"Connecting DICE+...";
}

- (void)diceManager:(DPDiceManager *)manager didConnectDie:(DPDie *)die
{
    //Available Dice+ connected and is ready for play.
    availableDie = nil;
    connectedDie = die;
    connectedDie.delegate = (id)self;
    self.status.text = @"Press play to begin.";
}

- (void)diceManager:(DPDiceManager *)manager failedConnectingDie:(DPDie *)die error:(NSError *)error
{
    //Dice+ failed connection attempt.
    availableDie = nil;
    connectedDie = nil;
    self.status.text = @"Connection failed... Searching...";
    
    [diceManager startScan];
}

- (void)diceManager:(DPDiceManager *)manager didDisconnectDie:(DPDie *)die error:(NSError *)error
{
    //Dice+ disconnected
    availableDie = nil;
    connectedDie = nil;
    self.status.text = @"Die disconnected... Searching...";
    
    [diceManager startScan];
}

- (void)dieFailedAuthorization:(DPDie *)die error:(NSError *)error
{
    //Dice+ authorization failed.
    self.status.text = @"Failed authorization";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStatus:nil];
    [super viewDidUnload];
}
@end
