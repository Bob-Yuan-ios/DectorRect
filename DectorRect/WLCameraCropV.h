//
//  WLCameraCropV.h
//  DectorRect
//
//  Created by mac on 2019/11/12.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLCGTransfromHelper.h"


NS_ASSUME_NONNULL_BEGIN

@interface WLCameraCropV : UIView


/// 是否开启手电筒
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

/// 是否开启闪关灯
@property (nonatomic,assign,getter=isFlashEnabled) BOOL enableFlash;

- (void)start;

- (void)stop;

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)(void))completionHandler;

- (void)completeWithBlock:(void(^)(TransformCIFeatureRect fe, UIImage *img, CGSize size))comBlock;

@end

NS_ASSUME_NONNULL_END
