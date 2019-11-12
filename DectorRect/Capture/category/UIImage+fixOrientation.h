//
//  UIImage+fixOrientation.h
//  MMCamScanner
//
//  Created by mac on 09/06/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (fixOrientation)

//- (UIImage *)fixOrientation;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

+ (UIImage*)renderImage:(NSString *)imagName;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
@end
