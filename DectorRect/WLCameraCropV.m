//
//  WLCameraCropV.m
//  DectorRect
//
//  Created by mac on 2019/11/12.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import "WLCameraCropV.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <GLKit/GLKit.h>
#import "WLCGTransfromHelper.h"

#import "WLDectV.h"

#import "UIImage+fixOrientation.h"

@interface WLCameraCropV ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CIContext *_coreImageContext;
    GLKView *_glkView;
    GLuint _renderBuffer;
    
    BOOL _isStopped;
    BOOL _borderDetectFrame;
    NSTimer *_borderDetectTimeKeeper;
    
    CAShapeLayer *_rectOverlay;//边缘识别遮盖
}

@property (nonatomic,strong) AVCaptureDevice *captureDevice;

@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,strong) EAGLContext *context;

@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property (nonatomic, assign) NSMutableDictionary *sortPoints;

@property (nonatomic, strong) UIImage *img;

@property (nonatomic, strong) UIImageView *curImgV;

@property (nonatomic, assign) TransformCIFeatureRect featureRect;
@end



@implementation WLCameraCropV


#pragma mark --
#pragma mark action

// 设置手电筒
- (void)setEnableTorch:(BOOL)enableTorch
{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableTorch)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

// 设置闪光灯
- (void)setEnableFlash:(BOOL)enableFlash
{
    _enableFlash = enableFlash;
    AVCaptureDevice *device = self.captureDevice;
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableFlash)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

/**
 开启摄像头
 */
- (void)start{
    [self.captureSession startRunning];
    
    _isStopped = NO;

    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
    // 每隔0.45监测
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:.45f target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
    
    [self hideGLKView:NO completion:nil];
}

/**
 关闭摄像头
 */
- (void)stop{
    _isStopped = YES;

    [self.captureSession stopRunning];
    
    [_borderDetectTimeKeeper invalidate];
    
    [self hideGLKView:YES completion:nil];

}

/**
 完成拍照
 */
- (void)completeWithBlock:(void(^)(TransformCIFeatureRect fe, UIImage *img, CGSize size))comBlock{
    comBlock(_featureRect, _img, self.bounds.size);
}


// 隐藏glkview
- (void)hideGLKView:(BOOL)hidden completion:(void(^)(void))completion{
    [UIView animateWithDuration:0.1 animations:^
     {
         self->_glkView.alpha = (hidden) ? 0.0 : 1.0;
     }
                     completion:^(BOOL finished)
     {
         if (!completion) return;
         completion();
     }];
}


// 聚焦动作
- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)(void))completionHandler
{
    AVCaptureDevice *device = self.captureDevice;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                completionHandler();
            }
            
            [device unlockForConfiguration];
        }
    }
    else
    {
        completionHandler();
    }
}

// 开启边缘识别
- (void)enableBorderDetectFrame{
    _borderDetectFrame = YES;
}


#pragma mark --
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    

    //通过sampleBuffer得到图片
    _img = [self imageFromSampleBuffer:sampleBuffer];
    self.curImgV.image = _img;
    
    if (_isStopped || !_borderDetectFrame || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    _borderDetectFrame = NO;
    
    NSLog(@"11111111111111:%@",NSStringFromCGRect(_curImgV.frame));
    [WLDectV detectEdgesImage:_img targetSize:_img.size comBlock:^(NSMutableDictionary * _Nonnull p) {
        NSLog(@"222222222222");

        if (_rectOverlay) {
            _rectOverlay.path = nil;
        }
        
        _featureRect = [WLDectV calFeatureRect:p imgSize:_img.size srcSize:self.bounds.size];
        [self drawOverLayer];
        
    }];
}

- (void)drawOverLayer{
    if (!_rectOverlay) {
        _rectOverlay = [CAShapeLayer layer];
        _rectOverlay.fillRule = kCAFillRuleEvenOdd;
        
        _rectOverlay.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
        _rectOverlay.strokeColor = [UIColor blueColor].CGColor;
        _rectOverlay.lineWidth = 1.0f;
    }
    
    if (!_rectOverlay.superlayer) {
        self.layer.masksToBounds = YES;
        [self.layer addSublayer:_rectOverlay];
    }
    NSLog(@"33333333333333");

    // 边缘识别路径
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:_featureRect.topLeft];
    [path addLineToPoint:_featureRect.topRight];
    [path addLineToPoint:_featureRect.bottomRight];
    [path addLineToPoint:_featureRect.bottomLeft];
    [path closePath];
    
    // 背景遮罩路径
    CGSize size = self.frame.size;
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(-5,
                                                                         -5,
                                                                         size.width + 10,
                                                                         size.height + 10)];
    [rectPath appendPath:path];
    
    _rectOverlay.path = rectPath.CGPath;
    NSLog(@"444444444444444");
}


// 把buffer流生成图片
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
#warning 如果选择UIImageOrientationRight图片会被旋转
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
 
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

#pragma mark --
#pragma mark init method
- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        
        NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *device = [possibleDevices firstObject];
        if (!device) return nil;
        
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        _captureSession = session;
        [session beginConfiguration];
        self.captureDevice = device;
        
        NSError *error = nil;
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        session.sessionPreset = AVCaptureSessionPresetPhoto;
        [session addInput:input];
        
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
        [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:dataOutput];
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [session addOutput:self.stillImageOutput];
        
        AVCaptureConnection *connection = [dataOutput.connections firstObject];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        if (device.isFlashAvailable)
        {
            [device lockForConfiguration:nil];
            [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
            
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device lockForConfiguration:nil];
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device unlockForConfiguration];
            }
        }
        
        [session commitConfiguration];
        
    }
    
    return _captureSession;
}

- (UIImageView *)curImgV{
    if (!_curImgV) {
        _curImgV = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_curImgV];
    }
    return _curImgV;
}

- (EAGLContext *)context{
    if (!_context) {
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        GLKView *view = [[GLKView alloc] initWithFrame:self.bounds];
        _glkView = view;

        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.context = _context;
        view.contentScaleFactor = 1.0f;
        view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        [self insertSubview:view atIndex:0];
        
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        
        _coreImageContext = [CIContext contextWithEAGLContext:_context];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}


@end
