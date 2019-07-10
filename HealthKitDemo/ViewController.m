//
//  ViewController.m
//  HealthKitDemo
//
//  Created by yunlong on 2017/6/9.
//  Copyright © 2017年 yunlong. All rights reserved.
//

#import "ViewController.h"
#import "HealthKitManager.h"
#import "CoreMotionManager.h"
#import "DayStepInfoEntity.h"
#import "Tool.h"
@interface ViewController ()
{
    BOOL isStepRefreshed;//防止程序被杀死后运行调两遍刷新步数
}
//label
@property(nonatomic,strong) UILabel *stepLabel;
@property(nonatomic,strong) UILabel *distanceLabel;
@property(nonatomic,strong) UILabel *kcalLabel;
@property(nonatomic,strong) UILabel *timeLabel;
//当前步数
@property (nonatomic,assign) NSInteger currentStepCount;
//当前距离
@property (nonatomic,assign) double currentDistance;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 100, 200, 40)];
    _stepLabel.backgroundColor = [UIColor greenColor];
    _stepLabel.textAlignment = NSTextAlignmentCenter;
    _stepLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_stepLabel];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 150, 200, 40)];
    _distanceLabel.backgroundColor = [UIColor greenColor];
    _distanceLabel.textAlignment = NSTextAlignmentCenter;
    _distanceLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_distanceLabel];
    
    _kcalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 424, 40)];
    _kcalLabel.backgroundColor = [UIColor greenColor];
    _kcalLabel.textAlignment = NSTextAlignmentCenter;
    _kcalLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_kcalLabel];
    
    _timeLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 424, 40)];
    _timeLabel.backgroundColor = [UIColor greenColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_timeLabel];
    
    //监听是否重新进入程序程序.（双击home切换/单击home再进入）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听程序是否将要失活
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    isStepRefreshed = YES;
    
    //获取当天步数
    [self getTotalStepCount];
    
    //获取当天距离
    [self getTotalDistance];
    
    //获取当天千卡路里
    [self getTotalKilocalorie:weight];
    
    //运动时长
    [self getSportTime];
    
    //获取瞬时步数+距离+千卡路里
    [self getCurrentStepCountAndDistanceAndKcal:weight];
    
   
    //获取前6天数据
    NSMutableArray *sixdaysStepInfo = [self get6DaysStepCountWithWeight:weight];
    NSLog(@"%@",sixdaysStepInfo);
    
    //获取当天每时步数
    [self getEveryStepCountsArr];

    
}
- (void)applicationDidBecomeActive:(NSNotification *)notification{
    if(isStepRefreshed)return;
    //获取当天步数
    [self getTotalStepCount];
    
    //获取当天距离
    [self getTotalDistance];
    
    //获取当天千卡路里
    [self getTotalKilocalorie:weight];
    //运动时长
    [self getSportTime];
    
    //获取瞬时步数+距离+千卡路里
    [self getCurrentStepCountAndDistanceAndKcal:weight];
    
    
    //获取前6天数据
    NSMutableArray *sixdaysStepInfo = [self get6DaysStepCountWithWeight:weight];
    NSLog(@"%@",sixdaysStepInfo);
    
    //获取当天每时步数
    [self getEveryStepCountsArr];
    
}
- (void)applicationWillResignActive:(NSNotification *)notification{
    
    isStepRefreshed = NO;
    
}
//一定要在视图消失时按条件销毁，此处是销毁所有
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]   removeObserver:self];
}
#pragma mark - 获取步数
- (void)getTotalStepCount{
    __block NSInteger healthkitStepCount = 0;
    __block NSInteger coremotionStepCount = 0;
    __weak ViewController *kself = self;
    //healthkit
    
    [[HealthKitManager sharedInstance] getStepCountWithPredicate:[HealthKitManager getStepPredicateForSample] withCompletion:^(NSString *stepValue, NSError *error) {
        healthkitStepCount = [stepValue integerValue];
        //找出最大的，再刷新UI
        kself.currentStepCount = MAX(healthkitStepCount, coremotionStepCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            _stepLabel.text = [NSString stringWithFormat:@"步数：%ld步", (long)kself.currentStepCount];
        });
    }];
    
    //coreMotion
    [[CoreMotionManager sharedInstance] isOpenCoreMotion:^(BOOL success) {
        if(success){
            [[CoreMotionManager sharedInstance] getStepCount:^(NSString * _Nonnull stepValue, NSError * _Nonnull error) {
                coremotionStepCount = [stepValue integerValue];
                //找出最大的，再刷新UI
                kself.currentStepCount = MAX(healthkitStepCount, coremotionStepCount);
                dispatch_async(dispatch_get_main_queue(), ^{
                    _stepLabel.text = [NSString stringWithFormat:@"步数：%ld步", (long)kself.currentStepCount];
                });
                
                
            }];
        }else{
            NSLog(@"运动与健身关闭了");
        }
        
    }];
    
    
    
    
    
    
}
#pragma mark - 瞬时步数+公里+卡路里
- (void)getCurrentStepCountAndDistanceAndKcal:(double)weightValue{
    __weak ViewController *kself = self;
    [[CoreMotionManager sharedInstance] isOpenCoreMotion:^(BOOL success) {
        if(success){
            [[CoreMotionManager sharedInstance] getCurrentStepCountAndDistance:^(NSString * _Nonnull stepValue, NSString * _Nonnull distanceValue, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _stepLabel.text = [NSString stringWithFormat:@"步数：%ld步", kself.currentStepCount+[stepValue integerValue]];
                    _distanceLabel.text = [NSString stringWithFormat:@"距离：%.2f公里",
                                           [Tool decimalNumber:(kself.currentDistance+[distanceValue doubleValue])/1000.0f]];
                    double kilometer= (kself.currentDistance+[distanceValue doubleValue])/1000.0f;
                    _kcalLabel.text = [NSString stringWithFormat:@"卡路里（千卡）：%.2f千卡",  [Tool decimalNumber:kilometer*weightValue*kcalUnit]];
                    
                });
                
            }];
        }else{
            NSLog(@"运动与健身关闭了");
        }
        
    }];
    
    
}
#pragma mark - 获取距离
- (void)getTotalDistance{
    __block double healthkitDistance;
    __block double coremotionDistance;
    __weak ViewController *kself = self;
    //healthkit
    
    [[HealthKitManager sharedInstance] getDistanceWithPredicate:[HealthKitManager getStepPredicateForSample] withCompletion:^(NSString *distanceValue, NSError *error) {
        healthkitDistance = [distanceValue doubleValue];
        //找出最大的，再刷新UI
        kself.currentDistance = MAX(healthkitDistance, coremotionDistance);
        dispatch_async(dispatch_get_main_queue(), ^{
            _distanceLabel.text = [NSString stringWithFormat:@"距离：%.2f千米", [Tool decimalNumber:kself.currentDistance/1000.0f]];
        });
        
        
    }];
    
    
    //coreMotion
    [[CoreMotionManager sharedInstance] isOpenCoreMotion:^(BOOL success) {
        if(success){
            [[CoreMotionManager sharedInstance] getDistance:^(NSString * _Nonnull distanceValue, NSError * _Nonnull error) {
                coremotionDistance = [distanceValue doubleValue];
                //找出最大的，再刷新UI
                kself.currentDistance = MAX(healthkitDistance, coremotionDistance);
                dispatch_async(dispatch_get_main_queue(), ^{
                    _distanceLabel.text = [NSString stringWithFormat:@"距离：%.2f千米", [Tool decimalNumber:kself.currentDistance/1000.0f]];
                });
                
            }];
        }else{
            NSLog(@"运动与健身关闭了");
        }
        
    }];
    
    
}
#pragma mark - 获取千卡路里
-(void)getTotalKilocalorie:(double)weightValue{
    __block double healthkitDistance;
    __block double coremotionDistance;
    
    //healthkit
    
    [[HealthKitManager sharedInstance] getDistanceWithPredicate:[HealthKitManager getStepPredicateForSample] withCompletion:^(NSString *distanceValue, NSError *error) {
        healthkitDistance = [distanceValue doubleValue];
        //找出最大的，再刷新UI
        double maxdistance = MAX(healthkitDistance, coremotionDistance);
        dispatch_async(dispatch_get_main_queue(), ^{
            _kcalLabel.text = [NSString stringWithFormat:@"卡路里（千卡）：%.2f千卡", [Tool decimalNumber:maxdistance/1000.f*weightValue*kcalUnit]];
        });
        
    }];
    
    
    //coreMotion
    [[CoreMotionManager sharedInstance] isOpenCoreMotion:^(BOOL success) {
        if(success){
            [[CoreMotionManager sharedInstance] getDistance:^(NSString * _Nonnull distanceValue, NSError * _Nonnull error) {
                coremotionDistance = [distanceValue doubleValue];
                //找出最大的，再刷新UI
                double maxdistance= MAX(healthkitDistance, coremotionDistance);
                dispatch_async(dispatch_get_main_queue(), ^{
                    _kcalLabel.text = [NSString stringWithFormat:@"卡路里（千卡）：%.2f千卡", [Tool decimalNumber:maxdistance/1000.f*weightValue*kcalUnit]];
                });
                
            }];
        }else{
            NSLog(@"运动与健身关闭了");
        }
        
    }];
    
    
    
}

#pragma mark - 获取运动时长（分）
- (void)getSportTime{
    
    [[HealthKitManager sharedInstance] getMinutesWithPredicate:[HealthKitManager getStepPredicateForSample] withCompletion:^(NSString *minutesValue, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _timeLabel.text = [NSString stringWithFormat:@"运动时长：%ld分钟",(long)[minutesValue integerValue] ];
        });
        
    }];
    
}

#pragma mark - 获取前6天步数-距离-千卡路里-运动时长数据

- (NSMutableArray *)get6DaysStepCountWithWeight:(double)weightValue{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    /*
     @param         sampleType      要检索的数据类型。
     @param         predicate       数据应该匹配的基准。
     @param         limit           返回的最大数据条数
     @param         sortDescriptors 数据的排序描述
     @param         resultsHandler  结束后返回结果
     */
    //    这个方法有待业务需求确定做更改，可以传是否首次使用参数+相差多少天，详解如下：（前提是登录时间存本地）（相差多少天这个有没有最大值？？？）
    //若上传服务器时间取出是空，证明是首次使用，就要取登录时间，计算登录时间与现在差多少天，如果是同一天，就不上传，否则上传
    //若取出上传服务器时间不是空，就用取出的时间与现在差多少天，如果是同一天，就不上传，否则上传
    
    //例如下面的6天
    
    //若首次使用，当天步数从登录开始算，就要判断登录那天startDate不是0时而是登录时间
    for (int i = 6; i > 0; i --) {   // for循环 取出每天的步数
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        NSDate *nowDate = [calendar dateFromComponents:components];
        NSDate * startTempDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-i toDate:nowDate options:0];
        NSDate * startDate = [HealthKitManager getStartDate:startTempDate];
        NSDate * endDate = [HealthKitManager getEndDate:startTempDate];
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:1];
        DayStepInfoEntity *stepinfo = [[DayStepInfoEntity alloc] init];
        //时间
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        stepinfo.date = [formatter stringFromDate:startDate];
        // 初始化信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        // 创建队列组
        dispatch_group_t group =  dispatch_group_create();
        // 创建并发队列
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        // 任务1
        dispatch_group_async(group, queue, ^{
            //步数
            
            [[HealthKitManager sharedInstance] getStepCountWithPredicate:predicate withCompletion:^(NSString *stepValue, NSError *error) {
                stepinfo.stepCount = [stepValue doubleValue];
                dispatch_semaphore_signal(semaphore);
            }];
            
            
        });
        // 信号量等于0时会一直等待，大于0时正常执行，并让信号量-1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 任务2
        dispatch_group_async(group, queue, ^{
            //距离公里+千卡路里
            
            [[HealthKitManager sharedInstance] getDistanceWithPredicate:predicate withCompletion:^(NSString *distanceValue, NSError *error) {
                stepinfo.distance = [Tool decimalNumber:[distanceValue doubleValue]/1000.f];
                stepinfo.calories = [Tool decimalNumber:[distanceValue doubleValue]/1000.f*weightValue*kcalUnit];
                dispatch_semaphore_signal(semaphore);
            }];
            
            
        });
        // 信号量等于0时会一直等待，大于0时正常执行，并让信号量-1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 任务3
        dispatch_group_async(group, queue, ^{
            //运动时长-分钟
            
            [[HealthKitManager sharedInstance] getMinutesWithPredicate:predicate withCompletion:^(NSString *minutesValue, NSError *error) {
                stepinfo.sportTime = [minutesValue doubleValue];
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [arr addObject:stepinfo];
        
    }
    return arr;
}
- (void)getEveryStepCountsArr{
    [[HealthKitManager sharedInstance] everyHourStepCountCompletion:^(NSMutableArray *hourStepsArray, NSError *error) {
        NSLog(@"当天每时步数数组%@",hourStepsArray);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











