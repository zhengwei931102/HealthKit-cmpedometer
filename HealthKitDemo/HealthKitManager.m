//
//  HealthKitManager.m
//  BJTResearch
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
#import "DayStepInfoEntity.h"
#import "Tool.h"
@interface HealthKitManager ()
//HKHealthStore类提供用于访问和存储用户健康数据的界面。
@property (nonatomic, strong) HKHealthStore *healthStore;
@end
@implementation HealthKitManager

#pragma mark - 健康单例
+ (instancetype)sharedInstance {
    static HealthKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthKitManager alloc] init];
    });
    return instance;
}


#pragma mark - 检查是否支持获取健康数据
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion {
        if (![HKHealthStore isHealthDataAvailable]) {
            NSError *error = [NSError errorWithDomain:@"不支持健康数据" code:1 userInfo:[NSDictionary dictionaryWithObject:@"HealthKit不可用" forKey:NSLocalizedDescriptionKey]];
            if (compltion != nil) {
                compltion(NO, error);
            }
            return;
        }else{
            if(self.healthStore == nil){
                self.healthStore = [[HKHealthStore alloc] init];
            }
            //组装需要读写的数据类型
            NSSet *readDataTypes = [self dataTypesRead];
            //注册需要读写的数据类型，也可以在“健康”APP中重新修改
            [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
                
                if (compltion != nil) {
                    compltion (success, error);
                }
            }];
        }
    
}


#pragma mark - 读权限
- (NSSet *)dataTypesRead{
    
    //步数
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //步数+跑步距离
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:stepCountType, distanceType,nil];
}

#pragma mark - 获取步数
- (void)getStepCountWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *stepValue, NSError *error))completion{
    
    //要检索的数据类型。
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*
     @param         sampleType      要检索的数据类型。
     @param         predicate       数据应该匹配的基准。
     @param         limit           返回的最大数据条数
     @param         sortDescriptors 数据的排序描述
     @param         resultsHandler  结束后返回结果
     */
    HKSampleQuery*query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            completion(0,error);
        }else{
            NSLog(@"resultCount = %ld result = %@",results.count,results);
            //把结果装换成字符串类型
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results){
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                NSDictionary *dict = (NSDictionary *)quantitySample.metadata;
                NSInteger wasUserEntered = [dict[@"HKWasUserEntered"]integerValue];
                if(wasUserEntered != 1){
                    totleSteps += usersHeight;
                }
                
            }
            completion([NSString stringWithFormat:@"%ld",(long)totleSteps],error);
        }
    }];
    [self.healthStore executeQuery:query];
}



#pragma mark - 获取距离
- (void)getDistanceWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *distanceValue, NSError *error))completion{
    
    //要检索的数据类型。
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*
     @param         sampleType      要检索的数据类型。
     @param         predicate       数据应该匹配的基准。
     @param         limit           返回的最大数据条数
     @param         sortDescriptors 数据的排序描述
     @param         resultsHandler  结束后返回结果
     */
    HKSampleQuery*query = [[HKSampleQuery alloc] initWithSampleType:distanceType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            completion(0,error);
        }else{
            NSLog(@"resultCount = %ld result = %@",results.count,results);
            //把结果装换成字符串类型
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results){
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit meterUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                NSDictionary *dict = (NSDictionary *)quantitySample.metadata;
                NSInteger wasUserEntered = [dict[@"HKWasUserEntered"]integerValue];
                if(wasUserEntered != 1){
                    totleSteps += usersHeight;
                }
                
            }
            completion([NSString stringWithFormat:@"%f",totleSteps],error);
        }
    }];
    [self.healthStore executeQuery:query];
}

#pragma mark - 获取运动时长
- (void)getMinutesWithPredicate:(NSPredicate *)predicate withCompletion:(void(^)(NSString *minutesValue, NSError *error))completion{
    //要检索的数据类型。
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*
     @param         sampleType      要检索的数据类型。
     @param         predicate       数据应该匹配的基准。
     @param         limit           返回的最大数据条数
     @param         sortDescriptors 数据的排序描述
     @param         resultsHandler  结束后返回结果
     */
    HKSampleQuery*query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error){
            completion(0,error);
        }else{
            //把结果装换成字符串类型
            double sumTime = 0;
            for(HKQuantitySample *quantitySample in results){
                NSDictionary *dict = (NSDictionary *)quantitySample.metadata;
                NSInteger wasUserEntered = [dict[@"HKWasUserEntered"]integerValue];
                if(wasUserEntered != 1){
                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
                    NSInteger interval = [zone secondsFromGMTForDate:quantitySample.endDate];
                    NSDate *startDate = [quantitySample.startDate dateByAddingTimeInterval:interval];
                    NSDate *endDate   = [quantitySample.endDate dateByAddingTimeInterval:interval];
                    sumTime += [endDate timeIntervalSinceDate:startDate];
                }
                
            }
            completion([NSString stringWithFormat:@"%ld",(long)sumTime/60],error);
        }
    }];
    [self.healthStore executeQuery:query];
}
#pragma mark 当天每时步数
- (void)everyHourStepCountCompletion:(void(^)(NSMutableArray *hourStepsArray, NSError *error))completion{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<24; i++) {
        DayStepInfoEntity *hourstep = [[DayStepInfoEntity alloc] init];
        hourstep.date = [NSString stringWithFormat:@"%02d",i];
        hourstep.stepCount = 0;
        [arr addObject:hourstep];
    }
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = 1;
    
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:[HealthKitManager getStepPredicateForSample] options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate dateWithTimeIntervalSince1970:0] intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        for (HKStatistics *statistic in result.statistics) {
            NSLog(@"\n%@ 至 %@", statistic.startDate, statistic.endDate);
            NSDate *tomorrowZeroDate =[HealthKitManager getStartDate:[Tool GetTomorrowDay:[NSDate date]]];
            if(statistic.startDate != tomorrowZeroDate){
                for (HKSource *source in statistic.sources) {
                    //去除手动添加的
                    if (![source.name isEqualToString:@"健康"]) {
                        NSLog(@"%@ -- %f",source, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                        NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"HH"];
                        NSString *hourStr = [formatter stringFromDate:statistic.startDate];
                        for (DayStepInfoEntity *step in arr) {
                            if([step.date isEqualToString:hourStr]){
                                step.stepCount = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                            }
                        }
                    }
                }
            }
            
        }
        completion(arr,error);
        
    };
    [self.healthStore executeQuery:collectionQuery];
}

//.........................计算时间................................
#pragma mark - 当天时间段
+ (NSPredicate *)getStepPredicateForSample {
    NSDate *now = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *startFormatValue = [NSString stringWithFormat:@"%@000000",[formatter stringFromDate:now]];
    NSString *endFormatValue = [NSString stringWithFormat:@"%@235959",[formatter stringFromDate:now]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * startDate = [formatter dateFromString:startFormatValue];
    NSDate * endDate = [formatter dateFromString:endFormatValue];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:1];
    return predicate;
}
#pragma mark - 开始时间
+ (NSDate *)getStartDate:(NSDate *)start{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *startFormatValue = [NSString stringWithFormat:@"%@000000",[formatter stringFromDate:start]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * startDate = [formatter dateFromString:startFormatValue];
    return  startDate;
}
#pragma mark - 结束时间
+ (NSDate *)getEndDate:(NSDate *)end{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *endFormatValue = [NSString stringWithFormat:@"%@235959",[formatter stringFromDate:end]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * endDate = [formatter dateFromString:endFormatValue];
    return  endDate;
}
@end












