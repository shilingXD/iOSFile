//
//  AppDelegate.h
//  xcxcx
//
//  Created by 孙冬 on 2020/5/29.
//  Copyright © 2020 ElonChan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;

- (void)saveContext;


@end

