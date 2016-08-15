//
//  ViewController.m
//  YZDashboard
//
//  Created by sunhong on 16/8/12.
//  Copyright © 2016年 sunhong. All rights reserved.
//

#import "ViewController.h"

#import "UIView+Extensions.h"
#import "DashboardView.h"

#import "GradientView.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface ViewController ()

@property (nonatomic, strong) DashboardView *dashboardView;

@property (nonatomic, strong) GradientView * gradientView;

@property (nonatomic, strong) UIButton * clickBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupGradientView];
    
    [self setupCircleView];
    
    UIButton *stareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stareButton.frame = CGRectMake(10.f, self.dashboardView.bottom + 50.f, SCREEN_WIDTH - 20.f, 38.f);
    [stareButton addTarget:self action:@selector(onStareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [stareButton setTitle:@"Start Animation" forState:UIControlStateNormal];
    [stareButton setBackgroundColor:[UIColor lightGrayColor]];
    stareButton.layer.masksToBounds = YES;
    stareButton.layer.cornerRadius = 4.f;
    [self.view addSubview:stareButton];
    
    _clickBtn = stareButton;
}

- (void)setupGradientView {
    self.gradientView = [[GradientView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.gradientView];
}

- (void)setupCircleView {
    self.dashboardView = [[DashboardView alloc] initWithFrame:CGRectMake(40.f, 70.f, SCREEN_WIDTH - 80.f, SCREEN_WIDTH - 80.f)];
    self.dashboardView.bgImage = [UIImage imageNamed:@"backgroundImage"];
//    self.dashboardView.percent = 0.f;
    [self.view addSubview:self.dashboardView];
}

- (void)onStareButtonClick:(UIButton *)sender {
    
    if (sender.selected) {
        [self.gradientView removeFromSuperview];
        self.gradientView = nil;
        [self.dashboardView removeFromSuperview];
        self.dashboardView = nil;
        
        [self setupGradientView];
        [self setupCircleView];
        
        [self.view bringSubviewToFront:self.clickBtn];
    }
    sender.selected = YES;
    
    NSString *startNO = @"350";
    NSString *toNO = @"693";
    [self.dashboardView refreshJumpNOFromNO:startNO toNO:toNO];
    
    __block typeof(self)blockSelf = self;
    self.dashboardView.TimerBlock = ^(NSInteger index) {
        [blockSelf.gradientView setUpBackGroundColorWithColorArrayIndex:index];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
