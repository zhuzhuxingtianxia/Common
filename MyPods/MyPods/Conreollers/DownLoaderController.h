//
//  DownLoaderController.h
//  MyPods
//
//  Created by ZZJ on 2019/10/15.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownLoaderController : UIViewController

@end

@interface DownLoaderCell : UITableViewCell
@property (copy, nonatomic)NSString *downLoadUrl;
@end

NS_ASSUME_NONNULL_END
