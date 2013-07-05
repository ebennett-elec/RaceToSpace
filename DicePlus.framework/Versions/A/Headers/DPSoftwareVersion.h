//
//  DPSoftwareVersion.h
//  Mac OS X SDK
//
//  Created by Janusz Bossy on 29.05.2013.
//  Copyright (c) 2013 Janusz Bossy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPSoftwareVersion : NSObject

- (id)initWithMajor:(unsigned int)major minor:(unsigned int)minor andBuild:(unsigned int)build;

@property (readonly) unsigned int major;
@property (readonly) unsigned int minor;
@property (readonly) unsigned int build;

@end
