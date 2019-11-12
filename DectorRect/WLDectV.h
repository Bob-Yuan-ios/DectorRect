//
//  WLDectV.h
//  DectorRect
//
//  Created by mac on 2019/11/12.
//  Copyright © 2019年 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCropView.h"
#import "WLCGTransfromHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLDectV : NSObject

+ (TransformCIFeatureRect)calFeatureRect:(NSMutableDictionary *)p  imgSize:(CGSize)imgSize
                                 srcSize:(CGSize)srcSize;

+ (CGPoint)tranImgPoint:(CGPoint)iP imgSize:(CGSize)imgSize srcSize:(CGSize)srcSize;

+ (CGPoint)pValue:(NSDictionary *)sortedPoints idx:(NSUInteger)idx;

+ (void)detectEdgesImage:(UIImage *)image targetSize:(CGSize)targetSize
                comBlock:(void(^)(NSMutableDictionary *sortedPoints))comBlock;


+ (void)cropAction:(UIImageView *)_sourceImageView cropV:(MMCropView *)_cropRect
          ajustImg:(UIImage *)_adjustedImage;

@end

NS_ASSUME_NONNULL_END
