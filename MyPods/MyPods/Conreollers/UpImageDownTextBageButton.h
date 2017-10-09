//
//  UpImageDownTextBageButton.h
//  MyPods
//
//  Created by Jion on 16/8/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ActionClick)(UIButton *sender);
@interface UpImageDownTextBageButton : UIButton
@property(nonatomic,strong)NSString  *badgeValue;
@property(nonatomic,copy)ActionClick actionClick;
-(instancetype)initWithFrame:(CGRect)frame ImageName:(NSString*)imageName;

-(instancetype)initWithFrame:(CGRect)frame Title:(NSString*)title ImageName:(NSString*)imageName Badge:(NSString*)badge;

@end
