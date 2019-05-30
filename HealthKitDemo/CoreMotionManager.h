//
//  CoreMotionManager.h
//  HealthKitDemo
//
//  Created by zw on 2019/4/28.
//  Copyright © 2019 yunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreMotionManager : NSObject
/**
 * 健康单例
 */
+ (instancetype)sharedInstance;

/**
 * 检查是否支持获取健康数据
 */
- (void)authorizeCoreMotion:(void(^)(BOOL success, NSError *error))compltion;
/**
 * 检查设置中是否开启运动与健身
*/
- (void)isOpenCoreMotion:(void(^)(BOOL success))compltion;
/**
 * 获取当天步数
 */
- (void)getStepCount:(void(^)(NSString *stepValue, NSError *error))completion;
/**
 * 获取实时步数-距离
 */
- (void)getCurrentStepCountAndDistance:(void(^)(NSString *stepValue,NSString *distanceValue, NSError *error))completion;
/**
 * 获取当天距离
 */
- (void)getDistance:(void(^)(NSString *distanceValue, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
