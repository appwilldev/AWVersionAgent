//
//  AWVersionAgent.m
//  AWVersionAgent
//
//  Created by Heyward Fann on 1/31/13.
//  Copyright (c) 2013 Appwill. All rights reserved.
//

#import "AWVersionAgent.h"

#define kAppleLookupURLTemplate     @"http://itunes.apple.com/lookup?id=%@"
#define kAppStoreURLTemplate        @"https://itunes.apple.com/app/id%@"

#define kUpgradeAlertMessage    NSLocalizedString(@"新版本发布了，当前版本: %@，最新版本: %@，现在就去 App Store 升级吧。", nil)
#define kUpgradeAlertAction     NSLocalizedString(@"upgrade", nil)

#define kAWVersionAgentLastNotificationDateKey      @"lastNotificationDate"
#define kAWVersionAgentLastCheckVersionDateKey      @"lastCheckVersionDate"

@interface AWVersionAgent ()
@property (nonatomic) NSString *appID;
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
        _delay = 3;
        
        if ([self.actionText length] == 0) {
            self.actionText = kUpgradeAlertAction;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showUpgradeNotification)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }

    return self;
}

- (NSString *)appID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AWVersionAgentAppID"];
}

- (void)setAppID:(NSString *)appID
{
    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"AWVersionAgentAppID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)actionText
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AWVersionAgentActionText"];
}

- (void)setActionText:(NSString *)actionText
{
    [[NSUserDefaults standardUserDefaults] setObject:actionText forKey:@"AWVersionAgentActionText"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkNewVersionForApp:(NSString *)appid
{
    self.appID = appid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:kAppleLookupURLTemplate, self.appID];
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
                    NSString *curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
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
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:self.delay];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        NSString *msg = self.alertMessage;
        if (msg == nil) {
            NSString *curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *newVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAppNewVersion"];
            msg = [NSString stringWithFormat:kUpgradeAlertMessage,
                             curVersion, newVersion];
        }
        
        notification.alertBody = msg;
        notification.alertAction = self.actionText;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970]
                                                  forKey:kAWVersionAgentLastNotificationDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)upgradeAppWithNotification:(UILocalNotification *)notification
{
    if ([notification.alertAction isEqualToString:self.actionText]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];

        NSString *url = [NSString stringWithFormat:kAppStoreURLTemplate, self.appID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

        self.newVersionAvailable = NO;
    }
}

- (BOOL)isNewVersion
{
    NSString* appNewVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAppNewVersion"];
    NSString* curVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (appNewVersion && curVersion && ![appNewVersion isEqualToString:curVersion]) {
        return YES;
    } else {
        return NO;
    }
}

@end
