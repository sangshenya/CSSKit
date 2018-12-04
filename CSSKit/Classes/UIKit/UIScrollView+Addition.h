//
//  UIScrollView+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Addition)

/**
 滑动到顶部
 
 @param animated animated description
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/**
 滑动到底部
 
 @param animated animated description
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 滑动到左边
 
 @param animated animated description
 */
- (void)scrollToLeftAnimated:(BOOL)animated;

/**
 滑动到右边
 
 @param animated animated description
 */
- (void)scrollToRightAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
