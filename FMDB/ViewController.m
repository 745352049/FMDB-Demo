//
//  ViewController.m
//  FMDB
//
//  Created by 水晶岛 on 2018/7/7.
//  Copyright © 2018年 水晶岛. All rights reserved.
//

#import "ViewController.h"
#import <FMDatabase.h>
#import <YYModel.h>
#import "StudentModel.h"
#import "EditTableViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define UI_SafeArea_Height ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34.0:0.0)
#define UI_NavBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height>20?88.0:64.0)

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>{
    FMDatabase *dataBase;
    NSString *filePath;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建数据库
    // 1、找到数据库存储路径
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath = [document stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"document %@", document);
    // 2、使用路径初始化FMDB对象
    dataBase = [FMDatabase databaseWithPath:filePath];
    [self creatTable];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self creatTable];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [dataBase close];
}
#pragma mark - 创建数据库、创建表
- (void)creatTable {
    // 3、判断数据库是否打开，打开时才执行sql语句
    if ([dataBase open]) {
        // 1 创建建表sql语句
        NSString *createSql = @"create table if not exists t_student(ID integer primary key autoincrement not null, name text, age text, sex text, userID text)";
        BOOL result = [dataBase executeUpdate:createSql];
        if (result) {
            [self.tableArray removeAllObjects];
            FMResultSet * resultSet = [dataBase executeQuery:@"select * from t_student"];
            while ([resultSet next]) {
                StudentModel *model = [[StudentModel alloc] init];
                model.userID = [resultSet objectForColumn:@"userID"];
                model.name = [resultSet objectForColumn:@"name"];
                model.age = [resultSet objectForColumn:@"age"];
                model.sex = [resultSet objectForColumn:@"sex"];
                model.ID = [resultSet objectForColumn:@"ID"];
                [self.tableArray addObject:model];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"建表失败 %d", result);
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    StudentModel *model = [self.tableArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name.length ? model.name : @"没有";
    cell.detailTextLabel.text = model.sex.length ? model.sex : @"没有";
    
    return cell;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        StudentModel *model = [self.tableArray objectAtIndex:indexPath.row];
        [dataBase open];
        //根据联系人的id进行删除
        [dataBase executeUpdateWithFormat:@"DELETE FROM t_student WHERE ID = %d",[model.ID intValue]];
        [dataBase close];
        [self.tableArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        StudentModel *model = [self.tableArray objectAtIndex:indexPath.row];
        FMResultSet * resultSet = [dataBase executeQuery:[NSString stringWithFormat:@"select * from t_student where ID = %d",[model.ID intValue]]];
        if ([resultSet next]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            EditTableViewController *editStoryVC = [storyBoard instantiateViewControllerWithIdentifier:@"EditTableViewControllerID"];
            editStoryVC.model = model;
            editStoryVC.dataBase = dataBase;
            [self.navigationController pushViewController:editStoryVC animated:YES];
        }
    }];
    editAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction,editAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
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
- (NSMutableArray *)tableArray {
    if (!_tableArray) {
        _tableArray = [[NSMutableArray alloc] init];
    }
    return _tableArray;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = CGRectMake(0, UI_NavBar_Height, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NavBar_Height);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 关闭数据库
    [dataBase close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
