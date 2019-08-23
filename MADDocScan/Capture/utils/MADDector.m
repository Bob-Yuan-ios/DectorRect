//
//  MADDector.m
//  MADDocScan
//
//  Created by mac on 2019/7/30.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import "MADDector.h"

@implementation MADDector

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (UIImage *)dectorImage:(UIImage *)UIImg
{
    CIImage *CIImg = [CIImage imageWithCGImage:UIImg.CGImage];

    // 获取边缘识别最大矩形
    CIRectangleFeature *rectangleFeature = [MADDector biggestRectangleInRectangles:
                                            [[MADDector highAccuracyRectangleDetector] featuresInImage:CIImg]];

    if (rectangleFeature)
    {
        CIImg = [MADDector correctPerspectiveForImage:CIImg withFeatures:rectangleFeature];
    }
    
    // 获取拍照图片
    UIGraphicsBeginImageContext(CGSizeMake(CIImg.extent.size.width, CIImg.extent.size.height));
    // UIImageOrientationDown
    [[UIImage imageWithCIImage:CIImg scale:1.0 orientation:UIImageOrientationUp] drawInRect:
     CGRectMake(0,0, CIImg.extent.size.width, CIImg.extent.size.height)];
    
    //# warn 这里的UIImageOrientationDown设置是和拍摄时图片的原始方向布局一样的，要是用UIImageOrientationRight的话会出现剪切的图片为横屏的，和原始的图片方向不同（做了一个90度的旋转）
//    [[UIImage imageWithCIImage:CIImg scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, CIImg.extent.size.height, CIImg.extent.size.width)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return image;
}

// 高精度边缘识别器
+ (CIDetector *)highAccuracyRectangleDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
                  });
    return detector;
}



// 选取feagure rectangles中最大的矩形
+ (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles
{
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}


/// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature
{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}


+ (CGPoint)convertCGPoint:(CGPoint)point1 fromSize1:(CGSize)rect1 toSize2:(CGSize)rect2 {
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

+ (CIImage *)correctPerspectiveForImage:(CIImage *)image withPointInfo:(NSArray *)pointArr
{
    if (!image) {
        return image;
    }
    
    
    
    if ([pointArr isKindOfClass:[NSArray class]] && 4 == pointArr.count) {
        NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGSize imageSize = image.extent.size;
        
        CGPoint p0 = [MADDector convertCGPoint:[pointArr[0] CGPointValue] fromSize1:imageSize toSize2:screenSize];
        CGPoint p1 = [MADDector convertCGPoint:[pointArr[1] CGPointValue] fromSize1:imageSize toSize2:screenSize];
        CGPoint p2 = [MADDector convertCGPoint:[pointArr[2] CGPointValue] fromSize1:imageSize toSize2:screenSize];
        CGPoint p3 = [MADDector convertCGPoint:[pointArr[3] CGPointValue] fromSize1:imageSize toSize2:screenSize];
        
        rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:p0];
        rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:p1];
        rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:p2];
        rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:p3];
        return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
    }
    return image;
}
@end
