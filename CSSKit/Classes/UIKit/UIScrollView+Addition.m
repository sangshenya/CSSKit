//
//  UIScrollView+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "UIScrollView+Addition.h"

@implementation UIScrollView (Addition)

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height + self.contentInset.bottom - self.bounds.size.height;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width + self.contentInset.right - self.bounds.size.width;
    [self setContentOffset:off animated:animated];
}

@end
