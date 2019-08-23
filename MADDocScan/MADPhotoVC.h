//
//  MADPhotoVC.h
//  MADDocScan
//
//  Created by mac on 2019/8/2.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PHOTO_CAMERA = 1,
    PHOTO_LIBRARY,
} PhotoType;


@interface MADPhotoVC : YSYBaseVC

@property (nonatomic, assign) PhotoType type;

@property (nonatomic, copy) void (^dealPhotoBlock)(UIImage *image);

@end

NS_ASSUME_NONNULL_END
