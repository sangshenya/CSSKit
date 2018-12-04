//
//  UIApplication+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Addition)

/// "Documents"在沙盒中文件夹路径
@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

/// "Caches"在沙盒中文件夹路径
@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

/// "Library"在沙盒中文件夹路径
@property (nonatomic, readonly) NSURL *libraryURL;
@property (nonatomic, readonly) NSString *libraryPath;

/// Application's Bundle Name (show in SpringBoard).
@property (nullable, nonatomic, readonly) NSString *appBundleName;

/// Application's Bundle ID.  e.g. "com.XXX.MyApp"
@property (nullable, nonatomic, readonly) NSString *appBundleID;

/// Application's Version.  e.g. "1.2.0"
@property (nullable, nonatomic, readonly) NSString *appVersion;

/// Application's Build number. e.g. "123"
@property (nullable, nonatomic, readonly) NSString *appBuildVersion;

/// app是否是盗版(不是从app store下载的)
@property (nonatomic, readonly) BOOL isPirated;

/// app是否正在被调试
@property (nonatomic, readonly) BOOL isBeingDebugged;

/// 当前线程内存使用大小 (错误返回-1)
@property (nonatomic, readonly) int64_t memoryUsage;

/// 当前线程CPU使用率 (错误返回-1);
@property (nonatomic, readonly) float cpuUsage;

/// 是否是扩展 http://www.cocoachina.com/ios/20140812/9366.html
+ (BOOL)isAppExtension;

/// 和sharedApplication一样,但是在扩展中返回nil
+ (nullable UIApplication *)sharedExtensionApplication;

@end

NS_ASSUME_NONNULL_END
