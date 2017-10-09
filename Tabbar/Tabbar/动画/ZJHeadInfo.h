//
//  ZJHeadInfo.h
//  Tabbar
//
//  Created by Jion on 15/10/23.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJWaterDropView.h"

@interface ZJHeadInfo : UIView
{
     BOOL touch1,touch2,hasStop;
    BOOL isrefreshed;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UIButton *bt_avatar;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet ZJWaterDropView *waterView;

@property (nonatomic,assign)BOOL touching;
@property (nonatomic,assign)CGFloat offsetY;
@property(copy,nonatomic)void(^handleRefreshEvent)(void) ;

+(instancetype)shareHeadInfo;
-(void)stopRefresh;
@end
