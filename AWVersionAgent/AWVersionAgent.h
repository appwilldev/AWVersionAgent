//
//  AWVersionAgent.h
//  AWVersionAgent
//
//  Created by Heyward Fann on 1/31/13.
//  Copyright (c) 2013 Appwill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWVersionAgent : NSObject

+ (AWVersionAgent *)sharedAgent;

@property (nonatomic) BOOL debug;

- (void)checkNewVersionForApp:(NSString *)appid;
- (void)upgradeAppWithNotification:(UILocalNotification *)notification;

@end
