//
//  EditTableViewController.h
//  FMDB
//
//  Created by 水晶岛 on 2018/7/10.
//  Copyright © 2018年 水晶岛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"
#import <FMDatabase.h>

@interface EditTableViewController : UITableViewController

@property (nonatomic, strong) StudentModel *model;
@property (nonatomic, strong) FMDatabase *dataBase;

@end
