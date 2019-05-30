//
//  TKNumberDefine.h
//  HealthKitDemo
//
//  Created by zw on 2019/4/29.
//  Copyright © 2019 yunlong. All rights reserved.
//

#ifndef TKNumberDefine_h
#define TKNumberDefine_h
//千卡路里计算公式 例如：体重60公斤的人，长跑8公里，那么消耗的热量＝60×8×1.036＝497.28 kcal(千卡)
#define  weight 60//test
#define  kcalUnit 1.036

#pragma mark - NSLog
#ifdef DEBUG // 调试状态, 打开LOG功能
// #define NSLog(...) NSLog(__VA_ARGS__)
//#define NSLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

#define NSLog(FORMAT, ...)                              fprintf(stderr,"\n File:%s__Line:%d__Msg:%s\n\n", [[[NSString stringWithUTF8String:__PRETTY_FUNCTION__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else // 发布状态, 关闭LOG功能
#define NSLog(...) NSLog(__VA_ARGS__)
#endif


#endif /* TKNumberDefine_h */
