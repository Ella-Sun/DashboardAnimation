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

@property (nonatomic, strong) UISlider * slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //创建背景色
    [self setupGradientView];
    
    //创建仪表盘
    [self setupCircleView];
    
    //添加触发动画的点击button
    [self addActionButton];
    
    //改变value
    [self addSlideChnageValue];
}

- (void)addActionButton {
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

- (void)addSlideChnageValue {
    
    CGFloat width = 280;
    CGFloat height = 40;
    CGFloat xPixel = (SCREEN_WIDTH - width) * 0.5;
    CGFloat yPixel = CGRectGetMaxY(_clickBtn.frame) + 20;
    CGRect slideFrame = CGRectMake(xPixel, yPixel, width, height);
    
    UISlider *slider = [[UISlider alloc] initWithFrame:slideFrame];
    
//    slider.minimumValue = 0;
    slider.maximumValue = 1000;
    
    slider.minimumTrackTintColor = [UIColor colorWithRed:0.000 green:1.000 blue:0.502 alpha:1.000];
    slider.maximumTrackTintColor = [UIColor colorWithWhite:0.800 alpha:1.000];
    /**
     *  注意这个属性：如果你没有设置滑块的图片，那个这个属性将只会改变已划过一段线条的颜色，不会改变滑块的颜色，如果你设置了滑块的图片，又设置了这个属性，那么滑块的图片将不显示，滑块的颜色会改变（IOS7）
     */
    [slider setThumbImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    slider.thumbTintColor = [UIColor cyanColor];
    
    
    [slider setValue:0.5 animated:YES];
    
    [slider addTarget:self action:@selector(slideTap:)forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
    
    _slider = slider;
}

- (void)slideTap:(UISlider *)sender {
    CGFloat value = sender.value;
    NSLog(@"%.f",value);
}

- (void)setupGradientView {
    self.gradientView = [[GradientView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.gradientView];
}

- (void)setupCircleView {
    self.dashboardView = [[DashboardView alloc] initWithFrame:CGRectMake(40.f, 70.f, SCREEN_WIDTH - 80.f, SCREEN_WIDTH - 80.f)];
    self.dashboardView.bgImage = [UIImage imageNamed:@"backgroundImage"];
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
        [self.view bringSubviewToFront:_slider];
    }
    sender.selected = YES;
    
    CGFloat value = _slider.value;
    
    NSString *startNO = @"0";
    NSString *toNO = [NSString stringWithFormat:@"%.f",value];//@"693";
    NSLog(@"endNO:%@",toNO);
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
