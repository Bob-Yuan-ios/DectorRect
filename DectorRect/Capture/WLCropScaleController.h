//
//  WLCropScaleController.h
//  DectorRect
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLCropScaleView.h"

@interface WLCropScaleController : YSYBaseVC

@property (nonatomic, strong) UIImage *cropImage;
@property (nonatomic, strong) CIRectangleFeature *borderDetectFeature;

@end
