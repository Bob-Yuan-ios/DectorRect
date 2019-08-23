//
//  WLCropScaleView.h
//  DectorRect
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLCropScaleView;
@protocol WLCropScaleViewDelegate <NSObject>

@optional

/// 绘制之前调用
- (void) beforeScaleViewTouched:(WLCropScaleView *) scaleView;
/// 绘制之后调用
- (void) afterScaleViewCleared:(WLCropScaleView *) scaleView;
/// 重置状态
- (void)reset;

@end

@interface WLCropScaleView : UIView

@property (nonatomic, assign) id <WLCropScaleViewDelegate> delegate;

// 划线宽度
@property (nonatomic, assign) NSInteger panWidth;
// 四角圆形半径
@property (nonatomic, assign) CGFloat cornerCircleRedis;
// 划线颜色
@property (nonatomic, assign) UIColor *panStrokColor;
// 初始截取框位置, 矩形
@property (nonatomic, assign) CGRect cropperFrame;

- (void)setCornerPointsWithTopLeft:(CGPoint)topLeft
                          topRight:(CGPoint)topRight
                        bottomLeft:(CGPoint)bottomLeft
                       bottomRight:(CGPoint)bottomRight;

- (NSArray *)getPointArr;
 
@end
