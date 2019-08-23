//
//  WLSnapshotButton.m
//  DectorRect
//
//  Created by mac on 2017/10/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WLSnapshotButton.h"

@implementation WLSnapshotButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _tintColor = [UIColor whiteColor];
        _circleOffset = 8.f;
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self setNeedsDisplay];
}

- (void)setCircleOffset:(CGFloat)circleOffset
{
    _circleOffset = circleOffset;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    
    UIColor *circleColor = _tintColor;
    
    // 外圆圈
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: rect];
    [[circleColor colorWithAlphaComponent:0.5] setFill];
    [ovalPath fill];
    // 内圆
    UIBezierPath* innerOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectInset(rect, _circleOffset, _circleOffset)];
    [circleColor setFill];
    [innerOvalPath fill];
}


@end
