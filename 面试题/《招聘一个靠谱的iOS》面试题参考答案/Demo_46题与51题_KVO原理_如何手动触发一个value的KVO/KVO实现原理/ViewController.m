//
//  ViewController.m
//  KVO实现原理
//
//  Created by 微博@iOS程序犭袁 on 16/4/6.
//  Copyright © 2016年 ElonChan. All rights reserved.
//
#import <objc/objc.h>
#import "ViewController.h"
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)
@interface ViewController ()
@property (nonatomic, strong) NSDate *now;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"now" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"dsdcd"];
    NSLog(@"1");
    [self willChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"2");
    [self didChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"4");
    SEL method= @selector(fub1);
    SuppressPerformSelectorLeakWarning(
                                       [self performSelector:method withObject:nil];
                                       );
    
    NSString *a = NSStringFromSelector(method);
    NSLog(@"%@",a);
    IMP methodimp = [self methodForSelector:method];
    methodimp();
    
    [Logging logWithEventName:@""];
}
- (void)fub1
{
    NSLog(@"知识");
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSLog(@"3");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"%@",NSStringFromSelector(sel));
    return [super resolveInstanceMethod:sel];
}
@end
