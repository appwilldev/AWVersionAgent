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
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) NSString *actionText;
@property (nonatomic, strong) NSString *alertMessage;

- (void)checkNewVersionForApp:(NSString *)appid;

- (BOOL)isNewVersion;

- (void)upgradeAppWithNotification:(UILocalNotification *)notification;

@end
