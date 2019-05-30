//
//  HealthKitManager.h
//  BJTResearch
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthKitManager : NSObject

/**
 * 健康单例
 */
+ (instancetype)sharedInstance;

/**
 * 检查是否支持获取健康数据
 */
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;

/**
 * 获取步数
 */
- (void)getStepCountWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *stepValue, NSError *error))completion;

/**
 * 获取距离
 */
- (void)getDistanceWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *distanceValue, NSError *error))completion;

/**
 * 获取运动时长
 */
- (void)getMinutesWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *minutesValue, NSError *error))completion;

/**
 * 当天每时步数
 */
- (void)everyHourStepCountCompletion:(void(^)(NSMutableArray *hourStepsArray, NSError *error))completion;


//........................计算时间.....................................
/**
 * 获取当天时间
 */
+ (NSPredicate *)getStepPredicateForSample;

/**
 * 开始时间
 */
+ (NSDate *)getStartDate:(NSDate *)start;

/**
 * 结束时间
 */
+ (NSDate *)getEndDate:(NSDate *)end;

@end
