//
//  UIColor+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "UIColor+Addition.h"

@implementation UIColor (Addition)

+ (nullable UIColor *)colorWithHexString:(NSString *)hexString {
    return [[self class] colorWithHexString:hexString alphaComponent:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alphaComponent:(CGFloat)alphaComponent {
    //删除字符串中的空格
    NSString *colorString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    //string should be 6 or 8 characters
    if ([colorString length] < 6) {
        return [UIColor clearColor];
    }
    //检查字符串是否以 0X 开头.如果是,从索引为2的位置截取字符串直到末尾
    if ([colorString hasPrefix:@"0X"]) {
        colorString = [colorString substringFromIndex:2];
    }
    //检查字符串是否以 # 开头.如果是,从索引为1的位置截取字符串直到末尾
    if ([colorString hasPrefix:@"#"]) {
        colorString = [colorString substringFromIndex:1];
    }
    if ([colorString length] != 6) {
        return [UIColor clearColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R
    NSString *rString = [colorString substringWithRange:range];
    //G
    range.location = 2;
    NSString *gString = [colorString substringWithRange:range];
    //B
    range.location = 4;
    NSString *bString = [colorString substringWithRange:range];
    
    //Scan values
    unsigned int r,g,b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r/255.0f) green:(float)g/255.0f blue:(float)b/255.0f alpha:alphaComponent];
}

- (NSString *)hexadecimalString {
    UIColor* color = self;
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+(UIColor *)randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

@end
