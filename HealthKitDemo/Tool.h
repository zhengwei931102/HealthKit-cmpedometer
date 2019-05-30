//
//  Tool.h
//  HealthKitDemo
//
//  Created by zw on 2019/4/28.
//  Copyright © 2019 yunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tool : NSObject
//时间转换
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;
//数值四舍五入问题
+ (double)decimalNumber:(double)number;
//传入今天的时间，返回明天的时间
+ (NSDate *)GetTomorrowDay:(NSDate *)aDate;
@end

NS_ASSUME_NONNULL_END
