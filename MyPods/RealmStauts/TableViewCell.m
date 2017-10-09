//
//  TableViewCell.m
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stautsImage;

@property(nonatomic,strong)TableModel  *model;

@end

@implementation TableViewCell

+(instancetype)sharedCellTable:(UITableView*)tableView withModel:(TableModel*)model{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    cell.model = model;
    return cell;
    
}

-(void)setModel:(TableModel *)model{
    _model = model;
    
    NSString *name = @"业主姓名:";
    _nameLabel.text = [name stringByAppendingString:_model.name];
    
    NSString *date = @"签约时间:";
    _dateLabel.text = [date stringByAppendingString:_model.sign_time];
    NSString *address = @"装修地址:";
    _addressLabel.text = [address stringByAppendingString:_model.address];
    
   NSInteger reviewed_status = [_model.reviewed_status integerValue];
    
    //0、1、5、8审核中； 2 未通过 ； 3、4、6已通过； 7 已打款; 9待跟进； 11无效
    if (reviewed_status == 0 || reviewed_status == 1 || reviewed_status == 5 || reviewed_status == 8){
        //审核中
        _bgImageView.image = [UIImage imageNamed:@"btn_yzbg_2.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_shz.png"];
        
    }else if (reviewed_status == 2){
        //未通过
        _bgImageView.image = [UIImage imageNamed:@"btn_yzbg_4.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_wtg.png"];
        
    }else if (reviewed_status == 3 || reviewed_status == 4 || reviewed_status == 6){
        //已通过
        _bgImageView.image = [UIImage imageNamed:@"btn_yzbg_1.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_ytg.png"];
        
    }else if(reviewed_status == 7){
        // 7 已打款
        _bgImageView.image = [UIImage imageNamed:@"btn_yzbg_3.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_ydk.png"];
        
        
    }else if (reviewed_status == 9){
        //待跟进
        _bgImageView.image = [UIImage imageNamed:@"btn_dgj_1.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_dgj.png"];
        
        
    }else if(reviewed_status == 11){
        // 11 无效
        _bgImageView.image = [UIImage imageNamed:@"btn_wx_3.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_wx.png"];
        
        
    }else{
        //审核中
        _bgImageView.image = [UIImage imageNamed:@"btn_yzbg_2.png"];
        _stautsImage.image = [UIImage imageNamed:@"btn_shz.png"];
        
        
    }

    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
