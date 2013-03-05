AWVersionAgent
----

There is so many update checker using `UIAlertView` to notify user to upgrade your app, but the alert will stop user's action. `AWVersionAgent` will check new version in background and notify user that new version is available from Local Notification.

Usage:
----

1. Add `[[AWVersionAgent sharedAgent] checkNewVersionForApp:@"your-app-id"];` in `application:didFinishLaunchingWithOptions:` to check new version in background.
1. Add `[[AWVersionAgent sharedAgent] upgradeAppWithNotification:notification];` in `application:didReceiveLocalNotification:` to response local notification.
1. You can enable debug mode by `[[AWVersionAgent sharedAgent] setDebug:YES];`.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];

    [[AWVersionAgent sharedAgent] checkNewVersion];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[AWVersionAgent sharedAgent] upgradeAppWithNotification:notification];
}
```

License
----
AWVersionAgent is available under the MIT license.
