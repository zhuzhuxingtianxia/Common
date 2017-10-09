//
//  UpImageDownTextBageButton.m
//  MyPods
//
//  Created by Jion on 16/8/22.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "UpImageDownTextBageButton.h"
#import <objc/objc-runtime.h>

@interface UpImageDownTextBageButton ()

@property(nonatomic,weak)UIButton  *badgeBtn;

@end
@implementation UpImageDownTextBageButton

-(UIButton*)badgeBtn{
    if (!_badgeBtn) {
        UIButton *badgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        badgeBtn.bounds = CGRectMake(0, 0, 20, 20);
        badgeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        
        if ([UIImage imageNamed:@"消息数量.png"]) {
            badgeBtn.adjustsImageWhenHighlighted = NO;
            badgeBtn.titleEdgeInsets = UIEdgeInsetsMake(-2, -2, 0, 0);
            [badgeBtn setBackgroundImage:[UIImage imageNamed:@"消息数量.png"] forState:UIControlStateNormal];
            
        }else{
            badgeBtn.enabled = NO;
            badgeBtn.layer.cornerRadius = badgeBtn.bounds.size.height/2;
            badgeBtn.layer.borderWidth = 1.0;
            badgeBtn.layer.borderColor = [[UIColor redColor] CGColor];
            [badgeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        }
        badgeBtn.hidden = YES;
        [self addSubview:badgeBtn];
        [badgeBtn addTarget:[self getCurrentViewController] action:@selector(targetActon:) forControlEvents:UIControlEventTouchUpInside];
        _badgeBtn = badgeBtn;
    }
    return _badgeBtn;
}
-(void)targetActon:(UIButton*)sender{
//    sender.tag = self.tag;
//    __weak typeof (self)weakSelf = self;
    if (self.actionClick) {
        self.actionClick(self);
    }
}
-(instancetype)init{
    if (self = [super init]) {
        [self loadBase];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame ImageName:(NSString*)imageName{
    self = [self initWithFrame:frame Title:nil ImageName:imageName Badge:nil];
    if (self) {
        
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Title:(NSString*)title ImageName:(NSString*)imageName Badge:(NSString*)badge {
    if (self = [super initWithFrame:frame]) {
       [self loadBase];
        if (title) {
            [self setTitle:title forState:UIControlStateNormal];
        }
        if (imageName) {
            [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
        self.badgeValue = badge;
    }
    
    return self;
}

-(void)loadBase{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self addTarget:[self getCurrentViewController] action:@selector(targetActon:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setBadgeValue:(NSString *)badgeValue{
    _badgeValue = badgeValue;
    if (badgeValue && [badgeValue integerValue] > 0) {
        self.badgeBtn.hidden = NO;
        [self.badgeBtn setTitle:badgeValue forState:UIControlStateNormal];
    }else{
      self.badgeBtn.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0,self.frame.size.height - 15, self.frame.size.width, self.titleLabel.frame.size.height);
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 15);
    self.badgeBtn.frame = CGRectMake(self.frame.size.width/2+2, self.frame.size.height/2-30, 20, 20);
}

-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
@end
