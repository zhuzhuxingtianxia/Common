//
//  UIView+Masonry_LJC.h
//  MyPods
//
//  Created by Jion on 15/9/18.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
@interface UIView (Masonry_LJC)

- (void) distributeSpacingHorizontallyWith:(NSArray*)views;

- (void) distributeSpacingVerticallyWith:(NSArray*)views;
@end
