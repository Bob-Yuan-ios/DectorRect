//
//  WLResultVC.h
//  DectorRect
//
//  Created by mac on 2019/7/30.
//  Copyright © 2019年 mac. All rights reserved.
//  显示识别后的图片：支持缩放

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLResultVC : UIViewController

/**
 最终处理好的图片
 */
@property (nonatomic, strong) UIImage *resultImg;

@end

NS_ASSUME_NONNULL_END
