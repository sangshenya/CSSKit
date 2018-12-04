//
//  UIBarButtonItem+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (Addition)

@property (nonatomic, copy) void (^actionBlock)(id sender);

@end

NS_ASSUME_NONNULL_END
