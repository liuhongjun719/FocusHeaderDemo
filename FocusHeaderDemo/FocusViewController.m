//
//  FocusViewController.m
//  FocusHeaderDemo
//
//  Created by 123456 on 16/4/5.
//  Copyright © 2016年 123456. All rights reserved.
//

#import "FocusViewController.h"
#import "HJFocusView.h"

@interface FocusViewController ()
@property (nonatomic, strong) HJFocusView *focusView;

@end



@implementation FocusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.view.backgroundColor = [UIColor whiteColor];
    self.focusView = [[HJFocusView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)];
    [self.view addSubview:self.focusView];
    
    //进入后台时取消定时；进入前台时重新添加定时，并从进入后台前的位置继续滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeTimer {
    [self.focusView removeTimer];
}

- (void)addTimer {
    [self.focusView addTimer];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeTimer];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addTimer];
}



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
