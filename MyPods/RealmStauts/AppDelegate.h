//
//  AppDelegate.h
//  RealmStauts
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

/*
 [!] The `RealmStauts [Debug]` target overrides the `other_ldflags` build setting defined in `Pods/Target Support Files/Pods-RealmStauts/Pods-RealmStauts.debug.xcconfig'. This can lead to problems with the CocoaPods installation
 
 [!] The `RealmStauts [Release]` target overrides the `OTHER_LDFLAGS` build setting defined in `Pods/Target Support Files/Pods-RealmStauts/Pods-RealmStauts.release.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.
 
 */
