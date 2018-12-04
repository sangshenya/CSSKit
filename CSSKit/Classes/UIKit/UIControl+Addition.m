//
//  UIControl+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "UIControl+Addition.h"
#import <objc/runtime.h>

static const int block_key;

@interface __CSSUIControlBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation __CSSUIControlBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end


@implementation UIControl (Addition)

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self __allUIControlBlockTargets] removeAllObjects];
}

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (!target || !action || !controlEvents) return;
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self removeTarget:currentTarget action:NSSelectorFromString(currentAction) forControlEvents:controlEvents];
        }
    }
    [self addTarget:self action:action forControlEvents:controlEvents];
}

- (void)addBlockTargetForControlEvents:(UIControlEvents)controlEvents block:(void(^)(id sender))block {
    if (!controlEvents) return;
    __CSSUIControlBlockTarget *target = [[__CSSUIControlBlockTarget alloc] initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self __allUIControlBlockTargets];
    [targets addObject:target];
}

- (void)setBlockTargetForControlEvents:(UIControlEvents)controlEvents block:(void(^)(id sender))block {
    [self removeAllBlocksTargetForControlEvents:controlEvents];
    [self addBlockTargetForControlEvents:controlEvents block:block];
}

- (void)removeAllBlocksTargetForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;
    NSMutableArray *targets = [self __allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (__CSSUIControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject: targets];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

// target出函数作用域会被释放,添加到array中
- (NSMutableArray *)__allUIControlBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
