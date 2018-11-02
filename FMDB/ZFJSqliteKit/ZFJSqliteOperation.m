//
//  ZFJSqliteOperation.m
//  FMDBDemo
//
//  Created by ZFJ on 2017/10/9.
//  Copyright © 2017年 ZFJ. All rights reserved.
//

#import "ZFJSqliteOperation.h"
#import "FMDatabase.h"
#import "ZFJSqliteTool.h"

@interface ZFJSqliteOperation ()

@property (nonatomic,retain) FMDatabase *dataBase;
@property (nonatomic,strong) dispatch_semaphore_t dsema;

@end

@implementation ZFJSqliteOperation

+ (ZFJSqliteOperation *)shareOperation{
    static ZFJSqliteOperation *open = nil;
    @synchronized(self) {
        if(open == nil){
            open = [[self alloc]init];
        }
        return open;
    }
}

- (id)init{
    if (self = [super init]){
        self.dsema = dispatch_semaphore_create(1);
    }
    return self;
}


#pragma mark - 创建表
- (BOOL)createTableWithtableName:(NSString *)tableName fieldNameModel:(NSObject *)fieldNameModel{
    NSArray *fieldNameArr = [ZFJSqliteTool allPropertyNamesFieldNameModel:fieldNameModel];
    NSString *fieldNameAll = [fieldNameArr componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@(%@)",tableName,fieldNameAll];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    return ret;
}

#pragma mark - 根据表名删除表
- (BOOL)delectTableWithtableName:(NSString *)tableName{
    NSMutableString *sqlStr = [[NSMutableString alloc]initWithFormat:@"drop table %@",tableName];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    return ret;
}

#pragma mark - 根据表名清空表
- (BOOL)cleanTableWithtableName:(NSString *)tableName{
    NSMutableString *sqlStr = [[NSMutableString alloc]initWithFormat:@"delete from %@",tableName];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    return ret;
}

#pragma mark - 根据数据模型插入一条数据
- (void)insertDataBaseWithtableName:(NSString *)tableName model:(NSObject *)model completed:(void(^)(BOOL isScu,NSString *meg))completed{
    NSDictionary *modelDict = [ZFJSqliteTool propertiesApsFieldNameModel:model];
    NSArray *fieldNameArr = modelDict.allKeys;
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<fieldNameArr.count; i++) {
        NSString *value = [modelDict objectForKey:fieldNameArr[i]];
        [valueArr addObject:[NSString stringWithFormat:@"'%@'",value]];
    }
    NSString *fieldNameAll = [fieldNameArr componentsJoinedByString:@","];
    NSString *valueAll = [valueArr componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",tableName,fieldNameAll,valueAll];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret,ret ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 根据数据模型数组插入多条数据
- (void)insertsDataBaseWithtableName:(NSString *)tableName modelArr:(NSArray *)modelArr completed:(void(^)(NSArray *failArr))completed{
    NSMutableArray *scuArr = [NSMutableArray new];
    NSMutableArray *failArr = [NSMutableArray new];
    dispatch_semaphore_wait([ZFJSqliteOperation shareOperation].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        if (modelArr != nil && modelArr.count > 0) {
            [modelArr enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL * _Nonnull stop) {
                [self insertDataBaseWithtableName:tableName model:model completed:^(BOOL isScu, NSString *meg) {
                    if(!isScu){
                        [failArr addObject:model];
                    }else{
                        [scuArr addObject:model];
                    }
                    if (!isScu) {*stop = YES;}
                    if(completed && (scuArr.count + failArr.count == modelArr.count)){
                        completed(failArr);
                    }
                }];
            }];
        }
    }
    dispatch_semaphore_signal([ZFJSqliteOperation shareOperation].dsema);
}

#pragma mark - 根据表的一个字段和一个值删除一条数据
- (void)delectDataBaseWithtableName:(NSString *)tableName fieldName:(NSString *)fieldName fieldNameValue:(NSString *)fieldNameValue completed:(void(^)(BOOL isScu,NSString *meg))completed{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tableName,fieldName,fieldNameValue];
    BOOL ret = [self.dataBase executeUpdate:deleteSql];
    if(completed){
        completed(ret,ret ? nil : ret ? nil : self.dataBase.lastErrorMessage);
    }
}

 #pragma mark - 根据条件删除多条数据
- (void)delectDataBaseWithtableName:(NSString *)tableName byParameter:(NSDictionary *)parameter selectType:(SelectType)selectType completed:(void(^)(BOOL isScu,NSString *meg))completed{
    NSArray *allKeys = parameter.allKeys;
    NSMutableArray *parameterArr = [[NSMutableArray alloc]init];
    for (NSString *keyStr in allKeys) {
        NSString *str = [NSString stringWithFormat:@"%@ = '%@'",keyStr,[parameter objectForKey:keyStr]];
        [parameterArr addObject:str];
    }
    NSString *parameterStr;
    if(selectType == KAndType){
        parameterStr = [parameterArr componentsJoinedByString:@" and "];
    }else if (selectType == KOrType){
        parameterStr = [parameterArr componentsJoinedByString:@" or "];
    }else{
        //
    }
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where %@",tableName,parameterStr];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret, ret ? nil : ret ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 自己写条件删除
- (void)delectDataBaseWithtableName:(NSString *)tableName sqlStr:(NSString *)sqlStr completed:(void(^)(BOOL isScu,NSString *meg))completed{
    sqlStr = [NSString stringWithFormat:@"delete from %@ where %@",tableName,sqlStr];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret, ret ? nil : ret ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 根据表的一个字段更新一条数据
- (void)updataTableWithtableName:(NSString *)tableName fieldName:(NSString *)fieldName model:(NSObject *)model completed:(void(^)(BOOL isScu,NSString *meg))completed{
    NSDictionary *modelDict = [ZFJSqliteTool propertiesApsFieldNameModel:model];
    NSArray *fieldNameArr = modelDict.allKeys;
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<fieldNameArr.count; i++) {
        NSString *value = [modelDict objectForKey:fieldNameArr[i]];
        value = [NSString stringWithFormat:@"%@ = '%@'",fieldNameArr[i],value];
        [valueArr addObject:value];
    }
    NSString *valueAll = [valueArr componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set %@ where %@ = %@",tableName,valueAll,fieldName,[modelDict objectForKey:fieldName]];
    BOOL ret = [self.dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret, ret ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 根据表的一个字段更新多条数据
- (void)updataTableWithtableName:(NSString *)tableName fieldName:(NSString *)fieldName modelArr:(NSArray *)modelArr completed:(void(^)(NSArray *failArr,NSString *meg))completed{
    NSMutableArray *scuArr = [NSMutableArray new];
    NSMutableArray *failArr = [NSMutableArray new];
    dispatch_semaphore_wait([ZFJSqliteOperation shareOperation].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        if (modelArr != nil && modelArr.count > 0) {
            [modelArr enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL * _Nonnull stop) {
                [self updataTableWithtableName:tableName fieldName:fieldName model:model completed:^(BOOL isScu, NSString *meg) {
                    if(!isScu){
                        [failArr addObject:model];
                    }else{
                        [scuArr addObject:model];
                    }
                    if (!isScu) {*stop = YES;}
                    if(completed && (scuArr.count + failArr.count == modelArr.count)){
                        completed(failArr, failArr.count > 0 ? nil : self.dataBase.lastErrorMessage);
                    }
                }];
            }];
        }
    }
    dispatch_semaphore_signal([ZFJSqliteOperation shareOperation].dsema);
}

#pragma mark - 查询表里面的全部数据
- (void)selectAllDataBaseWithtableName:(NSString *)tableName completed:(void(^)(NSArray *resultArr,NSString *meg))completed{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",tableName];
    FMResultSet *set = [self.dataBase executeQuery:sqlStr];
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [mutableArr addObject:dict];
    }
    [set close];
    if(completed){
        completed(mutableArr, mutableArr.count > 0 ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 根据参数条件查询
- (void)selectAllDataBaseWithtableName:(NSString *)tableName byParameter:(NSDictionary *)parameter selectType:(SelectType)selectType completed:(void(^)(NSArray *resultArr,NSString *meg))completed{
    NSArray *allKeys = parameter.allKeys;
    NSMutableArray *parameterArr = [[NSMutableArray alloc]init];
    for (NSString *keyStr in allKeys) {
        NSString *str = [NSString stringWithFormat:@"%@ = '%@'",keyStr,[parameter objectForKey:keyStr]];
        [parameterArr addObject:str];
    }
    NSString *parameterStr;
    if(selectType == KAndType){
        parameterStr = [parameterArr componentsJoinedByString:@" and "];
    }else if (selectType == KOrType){
        parameterStr = [parameterArr componentsJoinedByString:@" or "];
    }else{
        //
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where %@",tableName,parameterStr];
    FMResultSet *set = [self.dataBase executeQuery:sqlStr];
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [mutableArr addObject:dict];
    }
    [set close];
    if(completed){
        completed(mutableArr, mutableArr.count > 0 ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 自己写条件查询语句
- (void)selectAllDataBaseWithtableName:(NSString *)tableName sqlStr:(NSString *)sqlStr completed:(void(^)(NSArray *resultArr,NSString *meg))completed{
    if(sqlStr.length > 0){
        sqlStr = [NSString stringWithFormat:@"where %@",sqlStr];
    }else{
        sqlStr = @"";
    }
    sqlStr = [NSString stringWithFormat:@"select * from %@ %@",tableName,sqlStr];
    FMResultSet *set = [self.dataBase executeQuery:sqlStr];
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [mutableArr addObject:dict];
    }
    [set close];
    if(completed){
        completed(mutableArr, mutableArr.count > 0 ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 给表添加新的字段
- (void)addNewPropertyWithtableName:(NSString *)tableName propertyName:(NSString *)propertyName completed:(void(^)(BOOL isScu,NSString *meg))completed{
    NSString *alertStr = [NSString stringWithFormat:@"alter table %@ add %@ integer",tableName,propertyName];
    BOOL ret = [self.dataBase executeUpdate:alertStr];
    if(completed){
        completed(ret, ret ? nil : self.dataBase.lastErrorMessage);
    }
}

#pragma mark - 懒加载
- (FMDatabase *)dataBase{
    if(_dataBase == nil){
        NSLog(@"KDataBasePath == %@",KDataBasePath);
        _dataBase = [[FMDatabase alloc]initWithPath:KDataBasePath];
        [_dataBase open];
    }
    return _dataBase;
}


@end
