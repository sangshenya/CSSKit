//
//  UIBarButtonItem+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "UIBarButtonItem+Addition.h"
#import <objc/runtime.h>

static const int block_key;

@interface __CSSUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation __CSSUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id))block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end


@implementation UIBarButtonItem (Addition)

- (void)setActionBlock:(void (^)(id))actionBlock {
    __CSSUIBarButtonItemBlockTarget *target = [[__CSSUIBarButtonItemBlockTarget alloc] initWithBlock:actionBlock];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void (^)(id))actionBlock {
    __CSSUIBarButtonItemBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}

@end
