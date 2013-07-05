//
//  Player.m
//  RaceToSpace
//
//  Created by Erick Bennett on 6/26/13.
//  Copyright (c) 2013 Erick Bennett. All rights reserved.
//

#import "Player.h"

@implementation Player

-(id)initWithImage:(UIImage *)shipImage;
{
    self = [super init];
    if (self) {
        // Initialization code
        self.shipImage = shipImage;
        self.score = 0;
    }
    return self;
}

@end
