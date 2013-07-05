//
//  DPHardwareVersion.h
//  Mac OS X SDK
//
//  Created by Janusz Bossy on 29.05.2013.
//  Copyright (c) 2013 Janusz Bossy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPHardwareVersion : NSObject

- (id)initWithMajor:(unsigned int)major andMinor:(unsigned int)minor;

@property (readonly) unsigned int major;
@property (readonly) unsigned int minor;

@end
