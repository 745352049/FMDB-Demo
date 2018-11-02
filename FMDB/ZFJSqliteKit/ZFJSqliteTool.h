//
//  ZFJSqliteTool.h
//  FMDBDemo
//
//  Created by ZFJ on 2017/10/9.
//  Copyright © 2017年 ZFJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFJSqliteTool : NSObject

/**
 通过运行时获取当前对象的所有属性的名称，以数组的形式返回
 
 @param fieldNameModel 数据模型
 @return 返回数据模型的属性
 */
+ (NSArray *)allPropertyNamesFieldNameModel:(NSObject *)fieldNameModel;

/**
 Model转字典
 
 @param fieldNameModel 数据模型
 @return 转化后的字典
 */
+ (NSDictionary *)propertiesApsFieldNameModel:(NSObject *)fieldNameModel;

/**
 生成随机数
 
 @param from 开始值
 @param to 结束值
 @return 生成的随机数
 */
+ (int)getRandomNumber:(int)from to:(int)to;

@end
