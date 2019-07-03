//
//  LockViewController.m
//  MyPods
//
//  Created by ZZJ on 2019/7/3.
//  Copyright © 2019 Youjuke. All rights reserved.
//

#import "LockViewController.h"
#import <pthread.h>
#import <libkern/OSAtomic.h>
#import <QuartzCore/QuartzCore.h>
#import <os/lock.h>
typedef NS_ENUM(NSUInteger, LockType) {
    LockTypeOSSpinLock = 0,
    LockTypedispatch_semaphore,
    LockTypepthread_mutex,
    LockTypeNSCondition,
    LockTypeNSLock,
    LockTypepthread_mutex_recursive,
    LockTypeNSRecursiveLock,
    LockTypeNSConditionLock,
    LockTypesynchronized,
    LockTypepthread_rwlock,
    LockTypeos_unfair_lock,
    LockTypeCount,
};


NSTimeInterval TimeCosts[LockTypeCount] = {0};
int TimeCount = 0;

@interface LockViewController ()
@property(nonatomic,strong)UILabel  *textLabel;
@property (nonatomic,strong)NSArray *array;
@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.array = @[@"11111"];
    
    int buttonCount = 5;
    for (int i = 0; i < buttonCount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake((self.view.frame.size.width - 200)/2, 100+45*i, 200, 40);
        
        button.tag = pow(10, i + 3);
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"run (%d)",(int)button.tag] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    UIButton *logButton = [UIButton buttonWithType:UIButtonTypeSystem];
    logButton.frame = CGRectMake(15, [[UIScreen mainScreen] bounds].size.height - 100, 100, 50);
    [logButton setTitle:@"All Costs" forState:UIControlStateNormal];
    [logButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [logButton addTarget:self action:@selector(log:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logButton];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-115, [[UIScreen mainScreen] bounds].size.height - 100, 100, 50);
    [clearButton setTitle:@"Clear " forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
}

- (void)tap:(UIButton *)sender {
    self.textLabel.text = @"效果对比：\n";
    NSLog(@"%ld",(long)sender.tag);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test:(int)sender.tag];
    });
}

- (void)clear:(id)sender {
    self.textLabel.text = @"";
    for (NSUInteger i = 0; i < LockTypeCount; i++) {
        TimeCosts[i] = 0;
    }
    TimeCount = 0;
    printf("---- clear ----\n\n");
}

- (void)log:(id)sender {
    self.textLabel.text = @"效果对比：\n";
    [self printTimeConst:TimeCosts];
    printf("---- fin (sum:%d) ----\n\n",TimeCount);
}
- (void)test:(int)count {
    NSTimeInterval begin, end;
    TimeCount += count;
    NSTimeInterval timeCosts[LockTypeCount] = {0};
    
    {
        OSSpinLock lock = OS_SPINLOCK_INIT;
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            OSSpinLockLock(&lock);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            OSSpinLockUnlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeOSSpinLock] += end - begin;
        timeCosts[LockTypeOSSpinLock] = end - begin;
    }
    
    
    {
        dispatch_semaphore_t lock =  dispatch_semaphore_create(1);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            dispatch_semaphore_signal(lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypedispatch_semaphore] += end - begin;
        timeCosts[LockTypedispatch_semaphore] = end - begin;
    }
    {
        pthread_mutex_t lock;
        pthread_mutex_init(&lock, NULL);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_mutex_lock(&lock);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            pthread_mutex_unlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_mutex] += end - begin;
        timeCosts[LockTypepthread_mutex] = end - begin;
        pthread_mutex_destroy(&lock);
    }
    
    
    {
        NSCondition *lock = [NSCondition new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSCondition] += end - begin;
        timeCosts[LockTypeNSCondition] = end - begin;
    }
    {
        NSLock *lock = [NSLock new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSLock] += end - begin;
        timeCosts[LockTypeNSLock] = end - begin;
    }
    
    
    {
        pthread_mutex_t lock;
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&lock, &attr);
        pthread_mutexattr_destroy(&attr);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_mutex_lock(&lock);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            pthread_mutex_unlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_mutex_recursive] += end - begin;
        timeCosts[LockTypepthread_mutex_recursive] = end - begin;
        pthread_mutex_destroy(&lock);
    }
    {
        NSRecursiveLock *lock = [NSRecursiveLock new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSRecursiveLock] += end - begin;
        timeCosts[LockTypeNSRecursiveLock] = end - begin;
    }
    
    {
        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSConditionLock] += end - begin;
        timeCosts[LockTypeNSConditionLock] = end - begin;
    }
    {
        pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_rwlock_wrlock(&rwlock);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            pthread_rwlock_unlock(&rwlock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_rwlock] += end - begin;
        timeCosts[LockTypepthread_rwlock] = end - begin;
    }
    
    {
        os_unfair_lock_t unfairLock;
        unfairLock = &(OS_UNFAIR_LOCK_INIT);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            os_unfair_lock_lock(unfairLock);
            NSString *str = self.array.firstObject;
            NSLog(@"%@",str);
            os_unfair_lock_unlock(unfairLock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeos_unfair_lock] += end - begin;
        timeCosts[LockTypeos_unfair_lock] = end - begin;
        
    }
    {
        NSObject *lock = [NSObject new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            @synchronized(lock) {
                NSString *str = self.array.firstObject;
                NSLog(@"%@",str);
            }
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypesynchronized] += end - begin;
        timeCosts[LockTypesynchronized] = end - begin;
    }
    
    [self printTimeConst:timeCosts];
    
    printf("---- fin (%d) ----\n\n",count);
}
- (void)printTimeConst:(NSTimeInterval *)timeCosts {
    NSString *OSSpinLock = [NSString stringWithFormat:@"OSSpinLock:               %8.2f ms\n", timeCosts[LockTypeOSSpinLock] * 1000];
    NSString *dispatch_semaphore = [NSString stringWithFormat:@"dispatch_semaphore:       %8.2f ms\n", timeCosts[LockTypedispatch_semaphore] * 1000];
    NSString *pthread_mutex = [NSString stringWithFormat:@"pthread_mutex:            %8.2f ms\n", timeCosts[LockTypepthread_mutex] * 1000];
    NSString *NSCondition = [NSString stringWithFormat:@"NSCondition:              %8.2f ms\n", timeCosts[LockTypeNSCondition] * 1000];
    NSString *NSLock = [NSString stringWithFormat:@"NSLock:                   %8.2f ms\n", timeCosts[LockTypeNSLock] * 1000];
    NSString *pthread_mutex_recursive = [NSString stringWithFormat:@"pthread_mutex(recursive): %8.2f ms\n", timeCosts[LockTypepthread_mutex_recursive] * 1000];
    NSString *NSRecursiveLock = [NSString stringWithFormat:@"NSRecursiveLock:          %8.2f ms\n", timeCosts[LockTypeNSRecursiveLock] * 1000];
    NSString *NSConditionLock = [NSString stringWithFormat:@"NSConditionLock:          %8.2f ms\n", timeCosts[LockTypeNSConditionLock] * 1000];
    NSString *pthread_rwlock = [NSString stringWithFormat:@"pthread_rwlock:           %8.2f ms\n", timeCosts[LockTypepthread_rwlock] * 1000];
    NSString *os_unfair_lock = [NSString stringWithFormat:@"os_unfair_lock:           %8.2f ms\n", timeCosts[LockTypeos_unfair_lock] * 1000];
    NSString *synchronized = [NSString stringWithFormat:@"@synchronized:            %8.2f ms\n", timeCosts[LockTypesynchronized] * 1000];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeOSSpinLock] * 1000] forKey:OSSpinLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypedispatch_semaphore] * 1000] forKey:dispatch_semaphore];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_mutex] * 1000] forKey:pthread_mutex];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSCondition] * 1000] forKey:NSCondition];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSLock] * 1000] forKey:NSLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_mutex_recursive] * 1000] forKey:pthread_mutex_recursive];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSRecursiveLock] * 1000] forKey:NSRecursiveLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSConditionLock] * 1000] forKey:NSConditionLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_rwlock] * 1000] forKey:pthread_rwlock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeos_unfair_lock] * 1000] forKey:os_unfair_lock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypesynchronized] * 1000] forKey:synchronized];
    NSArray *relustArray =  [dict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 doubleValue] > [obj2 doubleValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 doubleValue] < [obj2 doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    for (NSString *string in relustArray) {
        printf("%s", [string UTF8String]);
        self.textLabel.text = [NSString stringWithFormat:@"%@\n%@",self.textLabel.text,string];
    }
}

#pragma mark -- getter

-(UILabel*)textLabel{
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor purpleColor];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.frame = CGRectMake(40, 100+45*4.5, 300, 450);
       
        _textLabel.text = @"效果对比：\n";
        [self.view addSubview:_textLabel];
    }
    return _textLabel;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
