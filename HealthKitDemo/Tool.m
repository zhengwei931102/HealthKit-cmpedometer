//
//  Tool.m
//  HealthKitDemo
//
//  Created by zw on 2019/4/28.
//  Copyright © 2019 yunlong. All rights reserved.
//

#import "Tool.h"

@implementation Tool
//由 NSDate 转换为 NSString
+ (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return  strDate;
}

//由 NSString 转换为NSDate
+ (NSDate *)dateFromString:(NSString *)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *lastdate = [dateFormatter dateFromString:string];
    return  lastdate;
}
//数值四舍五入问题
+ (double)decimalNumber:(double)number{
//NSRoundPlain:四舍五入
//NSRoundDown:只舍不入
//NSRoundUp：只入不舍
    NSDecimalNumberHandler *hander = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *num = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",number]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",1.0]] withBehavior:hander];
    return [num doubleValue];
}

//传入今天的时间，返回明天的时间
+ (NSDate *)GetTomorrowDay:(NSDate *)aDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    [components setDay:([components day]+1)];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    
    return beginningOfWeek;
}
@end
