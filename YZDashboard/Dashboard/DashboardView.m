//
//  DashboardView.m
//  YZDashboard
//
//  Created by sunhong on 16/8/12.
//  Copyright © 2016年 sunhong. All rights reserved.
//

#import "DashboardView.h"

#import "UIView+Extensions.h"

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
static const CGFloat kMarkerRadius = 5.f; // 光标直径
static const CGFloat kTimerInterval = 0.05;
static const CGFloat kFastProportion = 0.9;

static const NSInteger MaxNumber = 1000;

@interface DashboardView () {
    CGFloat animationTime;
    NSInteger beginNO;
    NSInteger jumpCurrentNO;
    NSInteger endNO;
}

// 百分比 0 - 100 根据跃动数字设置
@property (nonatomic, assign) CGFloat percent;

@property (nonatomic, strong) CAShapeLayer *bottomLayer; // 进度条底色
@property (nonatomic, assign) CGFloat lineWidth; // 弧线宽度

@property (nonatomic, strong) UIImageView *markerImageView; // 光标

@property (nonatomic, strong) UIImageView *bgImageView; // 背景图片

@property (nonatomic, assign) CGFloat circelRadius; //圆直径
@property (nonatomic, assign) CGFloat startAngle; // 开始角度
@property (nonatomic, assign) CGFloat endAngle; // 结束角度

@property (nonatomic, strong) UILabel * showLable;
@property (nonatomic, strong) NSTimer * fastTimer;
@property (nonatomic, strong) NSTimer * slowTimer;

@end

@implementation DashboardView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.circelRadius = self.frame.size.width - 10.f;
        self.lineWidth = 2.f;
        self.startAngle = -200.f;
        self.endAngle = 20.f;
        
        // 尺寸需根据图片进行调整
        self.bgImageView.frame = CGRectMake(6, 6, self.circelRadius, self.circelRadius * 2 / 3);
        self.bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgImageView];
        
        //添加圆框
        [self setupCircleBg];
        
        //光标
        [self setupMarkerImageView];
        
        //添加跃动数字
        [self setupJumpNOView];
    }
    return self;
}


- (void)setupCircleBg {
    
    // 圆形路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width / 2, self.height / 2)
                                                        radius:(self.circelRadius - self.lineWidth) / 2
                                                    startAngle:degreesToRadians(self.startAngle)
                                                      endAngle:degreesToRadians(self.endAngle)
                                                     clockwise:YES];
    
    // 底色
    self.bottomLayer = [CAShapeLayer layer];
    self.bottomLayer.frame = self.bounds;
    self.bottomLayer.fillColor = [[UIColor clearColor] CGColor];
    self.bottomLayer.strokeColor = [[UIColor  colorWithRed:206.f / 256.f green:241.f / 256.f blue:227.f alpha:1.f] CGColor];
    self.bottomLayer.opacity = 0.5;
    self.bottomLayer.lineCap = kCALineCapRound;
    self.bottomLayer.lineWidth = self.lineWidth;
    self.bottomLayer.path = [path CGPath];
    [self.layer addSublayer:self.bottomLayer];
    
    // 240 是用整个弧度的角度之和 |-200| + 20 = 220
//    [self createAnimationWithStartAngle:degreesToRadians(self.startAngle)
//                               endAngle:degreesToRadians(self.startAngle + 220 * 1)];
}

- (void)setupMarkerImageView {
    if (_markerImageView) {
        return;
    }
    _markerImageView = [[UIImageView alloc] init];
    _markerImageView.backgroundColor = [UIColor clearColor];
    _markerImageView.layer.backgroundColor = [UIColor greenColor].CGColor;
    _markerImageView.layer.shadowColor = [UIColor whiteColor].CGColor;
    _markerImageView.layer.shadowOffset = CGSizeMake(0, 0);
    _markerImageView.layer.shadowRadius = kMarkerRadius*0.5;
    _markerImageView.layer.shadowOpacity = 1;
    _markerImageView.layer.masksToBounds = NO;
    self.markerImageView.layer.cornerRadius = self.markerImageView.frame.size.height / 2;
    [self addSubview:self.markerImageView];
    _markerImageView.frame = CGRectMake(-100, self.height, kMarkerRadius, kMarkerRadius);
}

- (void)setupJumpNOView {
    if (_showLable) {
        return;
    }
    CGFloat xPixel = self.bgImageView.left + self.circelRadius / 4;
    CGFloat yPixel = self.circelRadius / 4;
    CGFloat width = self.circelRadius / 2;
    CGFloat height = self.circelRadius / 2;
    CGRect labelFrame = CGRectMake(xPixel, yPixel, width, height);
    _showLable = [[UILabel alloc] initWithFrame:labelFrame];
    _showLable.backgroundColor = [UIColor clearColor];
    _showLable.textColor = [UIColor whiteColor];
    _showLable.textAlignment = NSTextAlignmentCenter;
    _showLable.font = [UIFont systemFontOfSize:70.f];
    _showLable.text = [NSString stringWithFormat:@"%ld",jumpCurrentNO];
    [self addSubview:_showLable];
}

#pragma mark - Animation

- (void)createAnimationWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle { // 光标动画
    
    //启动定时器
    [_fastTimer setFireDate:[NSDate distantPast]];
    // 设置动画属性
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = _percent * kTimerInterval;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.repeatCount = 1;
    
    // 设置动画路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, self.width / 2, self.height / 2, (self.circelRadius - kMarkerRadius / 2) / 2, startAngle, endAngle, 0);
    pathAnimation.path = path;
    CGPathRelease(path);
    
    [self.markerImageView.layer addAnimation:pathAnimation forKey:@"moveMarker"];

}

#pragma mark - Setters / Getters


/**
 *  开始动画  确定百分比
 *
 */
- (void)refreshJumpNOFromNO:(NSString *)startNO toNO:(NSString *)toNO {
    
    beginNO = [startNO integerValue];
    jumpCurrentNO = [startNO integerValue];
    endNO = [toNO integerValue];
    _percent = endNO * 100 / MaxNumber;
    
    //数字
    [self setupJumpThings];
    
    //光标
    [self createAnimationWithStartAngle:degreesToRadians(self.startAngle)
                               endAngle:degreesToRadians(self.startAngle + 220 * _percent / 100)];
}

- (void)setBgImage:(UIImage *)bgImage {
    
    _bgImage = bgImage;
    self.bgImageView.image = bgImage;
}

- (UIImageView *)bgImageView {
    
    if (nil == _bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
    }
    return _bgImageView;
}

#pragma mark - 跃动数字

- (void)setupJumpThings {
    
    animationTime = _percent * kTimerInterval;
    
    self.fastTimer = [NSTimer timerWithTimeInterval:kTimerInterval*kFastProportion
                                             target:self
                                           selector:@selector(fastTimerAction)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_fastTimer forMode:NSRunLoopCommonModes];
    
    //时间间隔 = （总时间 - 快时间间隔*变化次数）/ 再次需要变化的次数
    NSTimeInterval slowInterval = (animationTime - endNO * kFastProportion*kTimerInterval*kFastProportion) / (endNO - jumpCurrentNO);
    self.slowTimer = [NSTimer timerWithTimeInterval:slowInterval
                                             target:self
                                           selector:@selector(slowTimerAction)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_slowTimer forMode:NSRunLoopCommonModes];
    [_fastTimer setFireDate:[NSDate distantFuture]];
    [_slowTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark 加速定时器触发事件
- (void)fastTimerAction {
    if (jumpCurrentNO == endNO) {
        [self.fastTimer invalidate];
        return;
    }
    if (jumpCurrentNO == endNO * kFastProportion) {
        [self.fastTimer invalidate];
        [self.slowTimer setFireDate:[NSDate distantPast]];
        return;
    }
    [self commonTimerAction];
}

#pragma mark 减速定时器触发事件
- (void)slowTimerAction {
    if (jumpCurrentNO == endNO) {
        [self.slowTimer invalidate];
        return;
    }
    [self commonTimerAction];
}

#pragma mark 计时器共性事件 - lable赋值 背景颜色变化
- (void)commonTimerAction {

    if (jumpCurrentNO % 100 == 0 && jumpCurrentNO != 0) {
        NSInteger colorIndex = jumpCurrentNO / 100;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.TimerBlock) {
                self.TimerBlock(colorIndex);
            }
//            [self setUpBackGroundColorWithColorArrayIndex:colorIndex];
        });
    }
    NSInteger changeValueBy = endNO - jumpCurrentNO;
    if (changeValueBy/10 <= 1) {
        jumpCurrentNO++;
    } else {
//        NSInteger changeBy = changeValueBy / 10;
        jumpCurrentNO += 10;
    }

    _showLable.text = [NSString stringWithFormat:@"%ld",jumpCurrentNO];
}


@end
