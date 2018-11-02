//
//  AddTableViewController.m
//  FMDB
//
//  Created by 水晶岛 on 2018/7/7.
//  Copyright © 2018年 水晶岛. All rights reserved.
//

#import "AddTableViewController.h"
#import <FMDatabase.h>

@interface AddTableViewController (){
    FMDatabase *dataBase;
}
@property (weak, nonatomic) IBOutlet UITextField *studentIdTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
    
@end

@implementation AddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"添加";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishAction)];
    self.navigationItem.rightBarButtonItem = item;
}
- (void)finishAction {
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [document stringByAppendingPathComponent:@"student.sqlite"];
    dataBase = [FMDatabase databaseWithPath:filePath];
    [dataBase open];
    if ([dataBase open]) {
        NSString *insertSql = @"insert into t_student(userID, name, age, sex) values (?, ?, ?, ?)";
        BOOL result = [dataBase executeUpdate:insertSql, _studentIdTF.text, _nameTF.text, _ageTF.text, _sexTF.text];
        if (result) {
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"学生添加成功");
        } else {
            NSLog(@"学生添加失败");
        }
    }
    [dataBase close];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
@end
