//
//  DashboardView.h
//  YZDashboard
//
//  Created by sunhong on 16/8/12.
//  Copyright © 2016年 sunhong. All rights reserved.
//
/**
 *  根据跃动数字
 *
 *  确定百分比
 *  现在的跳动数字——>背景颜色变化
 *
 */

#import <UIKit/UIKit.h>

@interface DashboardView : UIView

@property (nonatomic, strong) UIImage *bgImage;

@property (nonatomic, copy) void(^TimerBlock)(NSInteger);

/**
 *  跃动数字刷新
 *
 */
- (void)refreshJumpNOFromNO:(NSString *)startNO toNO:(NSString *)toNO;

@end
