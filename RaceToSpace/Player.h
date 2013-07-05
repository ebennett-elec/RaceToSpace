//
//  Player.h
//  RaceToSpace
//
//  Created by Erick Bennett on 6/26/13.
//  Copyright (c) 2013 Erick Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property(nonatomic, retain) UIImage *shipImage;
@property(nonatomic) NSInteger score;
@property(nonatomic) NSInteger playerNumber;

- (id)initWithImage:(UIImage *)shipImage;

@end
