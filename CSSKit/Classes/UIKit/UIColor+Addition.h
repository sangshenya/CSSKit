//
//  UIColor+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Addition)

/**
 十六进制数转颜色
 @param hexString 十六进制数
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)hexString;

/**
 十六进制数转颜色
 @param hexString 十六进制数
 @param alphaComponent 透明度 0~1
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)hexString alphaComponent:(CGFloat)alphaComponent;

/**
 当前颜色的十六进制值
 */
- (nullable NSString *)hexadecimalString;

/*
 随机颜色
 */
+(nullable UIColor *)randomColor;

@end

NS_ASSUME_NONNULL_END
