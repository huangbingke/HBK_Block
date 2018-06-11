
//
//  FirstViewController.m
//  HBK_Block
//
//  Created by 黄冰珂 on 2018/6/6.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "FirstViewController.h"

typedef void(^TestBlock)(void);

@interface FirstViewController ()

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) TestBlock testBlock;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#if 0
    __weak typeof(self) weakSelf = self;
    self.testBlock = ^{
        weakSelf.index = 10;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.index = 11;
            NSLog(@"====> %ld", weakSelf.index);
        });
    };
    self.testBlock();
    NSLog(@"%ld", self.index);
    
#endif
  
#if 1
    __weak typeof(self) weakSelf = self;
    self.testBlock = ^{
        weakSelf.index = 10;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            strongSelf.index = 11;
            NSLog(@"====> %ld", strongSelf.index);
        });
    };
    self.testBlock();
    NSLog(@"%ld", self.index);
#endif
}

- (void)dealloc {
    NSLog(@"======>>> 释放了 <<<======");
}
    /*
     若从A push到B，10s之内没有pop回A的话，B中block会执行打印出来11。
     若从A push到B，10s之内pop回A的话，B会立即执行dealloc，从而导致B中block打印出(null)。
     这种情况就是使用weakSelf的缺陷，可能会导致内存提前回收。
     */
    
    /*
     这么做和直接用self有什么区别，为什么不会有循环引用：外部的weakSelf是为了打破环，从而使得没有循环引用，而内部的strongSelf仅仅是个局部变量，存在栈中，会在block执行结束后回收，不会再造成循环引用。
     这么做和使用weakSelf有什么区别：唯一的区别就是多了一个strongSelf，而这里的strongSelf会使ClassB的对象引用计数＋1，使得ClassB pop到A的时候，并不会执行dealloc，因为引用计数还不为0，strongSelf仍持有ClassB，而在block执行完，局部的strongSelf才会回收，此时ClassB dealloc。
     */
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
