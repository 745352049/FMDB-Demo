//
//  EditTableViewController.m
//  FMDB
//
//  Created by 水晶岛 on 2018/7/10.
//  Copyright © 2018年 水晶岛. All rights reserved.
//

#import "EditTableViewController.h"

@interface EditTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ueerIDTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;

@end

@implementation EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"编辑";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = item;
}
- (void)saveAction {
    [_dataBase open];
    [_dataBase executeUpdateWithFormat:@"UPDATE t_student SET userID = %@, name = %@, age = %@, sex = %@ WHERE ID = %d",_ueerIDTF.text,_nameTF.text,_ageTF.text, _sexTF.text, [_model.ID intValue]];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.ueerIDTF.text = _model.userID;
    self.nameTF.text = _model.name;
    self.ageTF.text = _model.age;
    self.sexTF.text = _model.sex;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_dataBase close];
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
