//
//  TableViewCell.h
//  MyPods
//
//  Created by Jion on 2017/6/29.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableModel.h"
@interface TableViewCell : UITableViewCell

+(instancetype)sharedCellTable:(UITableView*)tableView withModel:(TableModel*)model;

@end
