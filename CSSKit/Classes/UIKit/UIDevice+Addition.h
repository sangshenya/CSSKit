//
//  UIDevice+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Addition)

#pragma mark - Device Information

/// 系统版本号 (e.g. 8.1)
+ (double)systemVersion;

/// 是否是iPad
@property (nonatomic, readonly) BOOL isPad;

/// 是否是模拟器
@property (nonatomic, readonly) BOOL isSimulator;

/// 是否越狱
@property (nonatomic, readonly) BOOL isJailbroken;

/// 能否打电话
@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// 系统启动时间(设备开机时间)
@property (nonatomic, readonly) NSDate *systemUptime;

#pragma mark - Disk Space

/// 总的磁盘空间字节 (错误情况返回-1)
@property (nonatomic, readonly) int64_t diskSpace;

/// 空闲磁盘空间字节 (错误情况返回-1)
@property (nonatomic, readonly) int64_t diskSpaceFree;

/// 已经使用磁盘空间字节 (错误情况返回-1)
@property (nonatomic, readonly) int64_t diskSpaceUsed;

#pragma mark - Memory Information

/// 总的物理内存字节 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryTotal;

/// 已经使用的内存,active+inactive+wired (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryUsed;

/// 空闲的内存 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryFree;

/// Acvite的内存 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryActive;

/// Inactive的内存 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryInactive;

/// Wired的内存 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryWired;

/// Purgable的内存 (错误情况返回-1)
@property (nonatomic, readonly) int64_t memoryPurgable;

#pragma mark - CPU Information

/// 几核CPU
@property (nonatomic, readonly) NSUInteger cpuCount;

/// 当前CPU使用率, 1.0 means 100% (错误情况返回-1)
@property (nonatomic, readonly) float cpuUsage;

/// 每核的使用率, 1.0 means 100% (错误情况返回-1)
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;

#pragma mark - 设备型号

/**
 获取设备型号, e.g. iPhone 2G (A1203)
 */
+ (NSString *)getCurrentDeviceModel;

/**
 获取设备型号(精简), e.g. iPhone 2G
 */
+ (NSString *)getCurrentDeviceShortModel;

/**
 获取屏幕密度
 */
+ (NSInteger)getCurrentDevicePPI;

@end

NS_ASSUME_NONNULL_END

#ifndef kSystemVersion
#define kSystemVersion [UIDevice systemVersion]
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif

#ifndef kiOS10Later
#define kiOS10Later (kSystemVersion >= 10)
#endif

#ifndef kiOS11Later
#define kiOS11Later (kSystemVersion >= 11)
#endif
