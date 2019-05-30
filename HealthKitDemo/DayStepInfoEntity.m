//
//  DayStepInfoEntity.m
//
//  Created by zw  on 2019/4/28
//  Copyright (c) 2019 __MyCompanyName__. All rights reserved.
//

#import "DayStepInfoEntity.h"


NSString *const kDayStepInfoEntitySportTime = @"sportTime";
NSString *const kDayStepInfoEntityCalories = @"calories";
NSString *const kDayStepInfoEntityStepCount = @"stepCount";
NSString *const kDayStepInfoEntityDistance = @"distance";
NSString *const kDayStepInfoEntityDate = @"date";


@interface DayStepInfoEntity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DayStepInfoEntity

@synthesize sportTime = _sportTime;
@synthesize calories = _calories;
@synthesize stepCount = _stepCount;
@synthesize distance = _distance;
@synthesize date = _date;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.sportTime = [[self objectOrNilForKey:kDayStepInfoEntitySportTime fromDictionary:dict] doubleValue];
            self.calories = [[self objectOrNilForKey:kDayStepInfoEntityCalories fromDictionary:dict] doubleValue];
            self.stepCount = [[self objectOrNilForKey:kDayStepInfoEntityStepCount fromDictionary:dict] doubleValue];
            self.distance = [[self objectOrNilForKey:kDayStepInfoEntityDistance fromDictionary:dict] doubleValue];
            self.date = [self objectOrNilForKey:kDayStepInfoEntityDate fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sportTime] forKey:kDayStepInfoEntitySportTime];
    [mutableDict setValue:[NSNumber numberWithDouble:self.calories] forKey:kDayStepInfoEntityCalories];
    [mutableDict setValue:[NSNumber numberWithDouble:self.stepCount] forKey:kDayStepInfoEntityStepCount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.distance] forKey:kDayStepInfoEntityDistance];
    [mutableDict setValue:self.date forKey:kDayStepInfoEntityDate];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.sportTime = [aDecoder decodeDoubleForKey:kDayStepInfoEntitySportTime];
    self.calories = [aDecoder decodeDoubleForKey:kDayStepInfoEntityCalories];
    self.stepCount = [aDecoder decodeDoubleForKey:kDayStepInfoEntityStepCount];
    self.distance = [aDecoder decodeDoubleForKey:kDayStepInfoEntityDistance];
    self.date = [aDecoder decodeObjectForKey:kDayStepInfoEntityDate];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_sportTime forKey:kDayStepInfoEntitySportTime];
    [aCoder encodeDouble:_calories forKey:kDayStepInfoEntityCalories];
    [aCoder encodeDouble:_stepCount forKey:kDayStepInfoEntityStepCount];
    [aCoder encodeDouble:_distance forKey:kDayStepInfoEntityDistance];
    [aCoder encodeObject:_date forKey:kDayStepInfoEntityDate];
}

- (id)copyWithZone:(NSZone *)zone
{
    DayStepInfoEntity *copy = [[DayStepInfoEntity alloc] init];
    
    if (copy) {

        copy.sportTime = self.sportTime;
        copy.calories = self.calories;
        copy.stepCount = self.stepCount;
        copy.distance = self.distance;
        copy.date = [self.date copyWithZone:zone];
    }
    
    return copy;
}


@end
