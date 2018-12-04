//
//  UIGestureRecognizer+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "UIGestureRecognizer+Addition.h"

#import <objc/runtime.h>

static const int block_key;

@interface __CSSUIGestureRecognizerBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (instancetype)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation __CSSUIGestureRecognizerBlockTarget

- (instancetype)initWithBlock:(void (^)(id sender))block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end


@implementation UIGestureRecognizer (Addition)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithActionBlock:(void (^)(id sender))block {
    self = [super init];
    [self addActionBlock:block];
    return self;
}
#pragma clang diagnostic pop

- (void)addActionBlock:(void (^)(id sender))block {
    __CSSUIGestureRecognizerBlockTarget *target = [[__CSSUIGestureRecognizerBlockTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self __allUIGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (void)removeAllActionBlocks {
    NSMutableArray *targets = [self __allUIGestureRecognizerBlockTargets];
    [targets enumerateObjectsUsingBlock:^(id  _Nonnull target, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTarget:target action:@selector(invoke:)];
    }];
    [targets removeAllObjects];
}

- (NSMutableArray *)__allUIGestureRecognizerBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
