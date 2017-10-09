//
//  ZJElasticHead.h
//  Tabbar
//
//  Created by Jion on 15/10/27.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJElasticHead : UIView
@property (nonatomic,assign)CGFloat offsetY;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

+(instancetype)shareElasticHead;
@end
