//
//  DayStepInfoEntity.h
//
//  Created by zw  on 2019/4/28
//  Copyright (c) 2019 __MyCompanyName__. All rights reserved.
//
//{
//    "calories" : 122.33,
//    "date" : "20190401",
//    "stepCount" : 10000,
//    "sportTime" : 100,
//    "distance" : 1.5800000000000001
//}
#import <Foundation/Foundation.h>



@interface DayStepInfoEntity : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double sportTime;
@property (nonatomic, assign) double calories;
@property (nonatomic, assign) double stepCount;
@property (nonatomic, assign) double distance;
@property (nonatomic, strong) NSString *date;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
