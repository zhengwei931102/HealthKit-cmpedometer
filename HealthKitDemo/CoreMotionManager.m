//
//  CoreMotionManager.m
//  HealthKitDemo
//
//  Created by zw on 2019/4/28.
//  Copyright © 2019 yunlong. All rights reserved.
//

#import "CoreMotionManager.h"
#import <CoreMotion/CoreMotion.h>
@interface CoreMotionManager ()
@property (nonatomic, strong) CMPedometer * pedometer;
@end
@implementation CoreMotionManager
#pragma mark - 健康单例
+ (instancetype)sharedInstance {
    static CoreMotionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreMotionManager alloc] init];
    });
    return instance;
}


#pragma mark - 检查是否支持获取健康数据
- (void)authorizeCoreMotion:(void(^)(BOOL success, NSError *error))compltion {
    if (!([CMPedometer isStepCountingAvailable] || [CMMotionActivityManager isActivityAvailable])) {
        NSError *error = [NSError errorWithDomain:@"不支持健康数据" code:1 userInfo:[NSDictionary dictionaryWithObject:@"抱歉，不能运行哦,只支持iOS 8.0以上及iPhone5s以上机型." forKey:NSLocalizedDescriptionKey]];
        compltion(NO, error);
        
    }else{
        if(self.pedometer == nil){
            self.pedometer = [[CMPedometer alloc] init];
        }
        compltion(YES, nil);
        
    }
}
#pragma mark - 检查设置中是否开启运动与健身
- (void)isOpenCoreMotion:(void(^)(BOOL success))compltion{
    
    CMMotionActivityManager *activityManager = [[CMMotionActivityManager alloc] init];
    [activityManager queryActivityStartingFromDate:[NSDate date] toDate:[NSDate date] toQueue:[[NSOperationQueue alloc] init] withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
        if(error!=nil && error.code==CMErrorMotionActivityNotAuthorized){
            NSLog(@"设置中运动与健身关闭了");
            compltion(NO);
        }else{
            compltion(YES);
        }
    }];
    
}
#pragma mark - 获取当天步数
- (void)getStepCount:(void(^)(NSString *stepValue, NSError *error))completion{
    if ([CMPedometer isStepCountingAvailable]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        // 开始日期
        NSDate *startDate = [calendar dateFromComponents:components];
        // 结束日期
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
        [self.pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error) {
                
                completion(0,error);
                
            }else{
                completion([NSString stringWithFormat:@"%@",pedometerData.numberOfSteps],error);
                
            }
        }];
    }
    
}
#pragma mark - 获取瞬时步数-距离（从调方法开始时间算起）
- (void)getCurrentStepCountAndDistance:(void(^)(NSString *stepValue,NSString *distanceValue, NSError *error))completion{
    if ([CMPedometer isStepCountingAvailable]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:now];
        // 当前时分秒
        NSDate *startDate = [calendar dateFromComponents:components];
        [self.pedometer startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            
            if (error) {
                
                completion(0,0,error);
                
            }else{
                completion([NSString stringWithFormat:@"%@",pedometerData.numberOfSteps],[NSString stringWithFormat:@"%@",pedometerData.distance],error);
                
            }
        }];
    }
}

#pragma mark - 获取当天距离
- (void)getDistance:(void(^)(NSString *distanceValue, NSError *error))completion{
    if ([CMPedometer isDistanceAvailable]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        // 开始日期
        NSDate *startDate = [calendar dateFromComponents:components];
        // 结束日期
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
        [self.pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error) {
                
                completion(0,error);
                
            }else{
                completion([NSString stringWithFormat:@"%f",[pedometerData.distance doubleValue]],error);
                
            }
        }];
    }
}
@end

