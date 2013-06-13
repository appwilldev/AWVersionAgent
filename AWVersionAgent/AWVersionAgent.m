//
//  AWVersionAgent.m
//  AWVersionAgent
//
//  Created by Heyward Fann on 1/31/13.
//  Copyright (c) 2013 Appwill. All rights reserved.
//

#import "AWVersionAgent.h"

#define kAppleLookupURLTemplate     @"http://itunes.apple.com/lookup?id=%@"
#define kAppStoreURLTemplate        @"itms-apps://itunes.apple.com/app/id%@"

#define kUpgradeAlertMessage    @"A new version is available, current version: %@, new version: %@. Upgrade from the App Store now."
#define kUpgradeAlertAction     @"kUpgradeAlertAction"
#define kUpgradeAlertDelay      3

#define kAWVersionAgentLastNotificationDateKey      @"lastNotificationDate"
#define kAWVersionAgentLastCheckVersionDateKey      @"lastCheckVersionDate"

@interface AWVersionAgent ()

@property (nonatomic, copy) NSString *appid;
@property (nonatomic) BOOL newVersionAvailable;

@end

@implementation AWVersionAgent

+ (AWVersionAgent *)sharedAgent
{
    static AWVersionAgent *sharedAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[AWVersionAgent alloc] init];
    });

    return sharedAgent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        _newVersionAvailable = NO;
        _debug = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showUpgradeNotification)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }

    return self;
}

- (void)checkNewVersionForApp:(NSString *)appid
{
    self.appid = appid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:kAppleLookupURLTemplate, _appid];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (data && [data length]>0) {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)obj;
                NSArray *array = dict[@"results"];
                if (array && [array count]>0) {
                    NSDictionary *app = array[0];
                    NSString *newVersion = app[@"version"];
                    [[NSUserDefaults standardUserDefaults] setObject:newVersion
                                                              forKey:@"kAppNewVersion"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
                    if (newVersion && curVersion && ![newVersion isEqualToString:curVersion]) {
                        self.newVersionAvailable = YES;
                    }
                }
            }
        }
    });
}

- (BOOL)conditionHasBeenMet
{
    if (_debug) {
        return YES;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval last = [defaults doubleForKey:kAWVersionAgentLastNotificationDateKey];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (last <= 0) {
        [defaults setDouble:now forKey:kAWVersionAgentLastNotificationDateKey];
        [defaults synchronize];

        return NO;
    }
    if (now - last < 60*60*24) {
        return NO;
    }

    return _newVersionAvailable;
}

- (void)showUpgradeNotification
{
    if ([self conditionHasBeenMet]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:kUpgradeAlertDelay];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        NSString *curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *newVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAppNewVersion"];
        NSString *msg = [NSString stringWithFormat:kUpgradeAlertMessage,
                         curVersion, newVersion];
        notification.alertBody = msg;
        notification.alertAction = kUpgradeAlertAction;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970]
                                                  forKey:kAWVersionAgentLastNotificationDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)upgradeAppWithNotification:(UILocalNotification *)notification
{
    if ([notification.alertAction isEqualToString:kUpgradeAlertAction]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];

        NSString *url = [NSString stringWithFormat:kAppStoreURLTemplate, _appid];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

        self.newVersionAvailable = NO;
    }
}

@end
