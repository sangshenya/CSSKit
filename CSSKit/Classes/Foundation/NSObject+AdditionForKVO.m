//
//  NSObject+AdditionForKVO.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "NSObject+AdditionForKVO.h"
#import <objc/runtime.h>

static const int block_key;

@interface __CSSNSObjectKVOBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldVal, id newVal);

- (instancetype)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block;

@end

@implementation __CSSNSObjectKVOBlockTarget

- (instancetype)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!self.block) return;
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
}

@end


@implementation NSObject (AdditionForKVO)

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(id obj, id oldVal, id newVal))block {
    __CSSNSObjectKVOBlockTarget *target = [[__CSSNSObjectKVOBlockTarget alloc] initWithBlock:block];
    NSMutableDictionary *dic = [self __allNSObjectKVOBlocks];
    NSMutableArray *arr = dic[keyPath];
    if (!arr) {
        arr = [NSMutableArray array];
        dic[keyPath] = arr;
    }
    [arr addObject:target];
    
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self __allNSObjectKVOBlocks];
    NSMutableArray *arr = dic[keyPath];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull target, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:target forKeyPath:keyPath];
    }];
    [dic removeObjectForKey:keyPath];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self __allNSObjectKVOBlocks];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * keyPath, NSArray *targets, BOOL * _Nonnull stop) {
        [targets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeObserver:obj forKeyPath:keyPath];
        }];
    }];
    
    [dic removeAllObjects];
}

- (NSMutableDictionary *)__allNSObjectKVOBlocks {
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end

