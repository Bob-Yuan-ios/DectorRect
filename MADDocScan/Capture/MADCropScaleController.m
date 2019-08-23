//
//  MADCropScaleController.m
//  MADDocScan
//
//  Created by 梁宪松 on 2017/11/8.
//  Copyright © 2017年 梁宪松. All rights reserved.
//

#import "MADCropScaleController.h"
#import "Masonry.h"
#import "MADCGTransfromHelper.h"

#import "MADResultVC.h"
#import "MADDector.h"

 
@interface MADCropScaleController ()

// 拉伸图
@property (nonatomic, strong) MADCropScaleView *cropScaleView;
// 完成按钮
@property (nonatomic, strong) UIButton *finishBtn;
// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation MADCropScaleController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_cropImage) {
        self.view.layer.contents = (__bridge id _Nullable)(_cropImage.CGImage);
    }
    
    [self.view addSubview:self.cropScaleView];

    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.finishBtn];

    if (_borderDetectFeature && _cropImage) {// 识别到了边缘
        
        // 拍照时候 设置了 UIImageOrientationRight， 所以要变换 extent
//        CGRect extent = CGRectMake(0, 0, _cropImage.size.width, _cropImage.size.height);
        
        // 转换成UIKit坐标系
//        CGAffineTransform transform = CGAffineTransformIdentity;
        
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, self.view.bounds.size.height);
//        transform = CGAffineTransformScale(transform, 1, -1);
//        transform = CGAffineTransformRotate(transform, -M_PI*3/2);
//
//        CGPoint topLeft = CGPointApplyAffineTransform(_borderDetectFeature.topLeft, transform);
//        CGPoint topRight = CGPointApplyAffineTransform(_borderDetectFeature.topRight, transform);
//        CGPoint bottomRight = CGPointApplyAffineTransform(_borderDetectFeature.bottomRight, transform);
//        CGPoint bottomLeft = CGPointApplyAffineTransform(_borderDetectFeature.bottomLeft, transform);
//
//        TransformCIFeatureRect rect =  [MADCGTransfromHelper transfromRealCIRectInPreviewRect:self.view.bounds imageRect:extent topLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight];
//
//        [_cropScaleView setCornerPointsWithTopLeft:rect.topLeft topRight:rect.topRight bottomLeft:rect.bottomLeft bottomRight:rect.bottomRight];
        
    }else// 没有识别到边缘
    {
        CGRect rect = self.view.bounds;
        rect = CGRectInset(rect, 80, 80);
        _cropScaleView.cropperFrame = rect;
    }
    
    [self.view setNeedsUpdateConstraints];
}


//- (void)cropImage{
////    //Thanks To stackOverflow
////    CGFloat scaleFactor =  1;//[_cropScaleView.cropperFrame contentScale];
////
////    CGPoint ptBottomLeft = [_cropScaleView.cropperFrame coordinatesForPoint:1 withScaleFactor:scaleFactor];
////    CGPoint ptBottomRight = [_cropScaleView.cropperFrame coordinatesForPoint:2 withScaleFactor:scaleFactor];
////    CGPoint ptTopRight = [_cropScaleView.cropperFrame coordinatesForPoint:3 withScaleFactor:scaleFactor];
////    CGPoint ptTopLeft = [_cropScaleView.cropperFrame coordinatesForPoint:4 withScaleFactor:scaleFactor];
////
////    CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
////    CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
////
////    CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
////    CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
////
////    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
////    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
////
////    cv::Point2f src[4], dst[4];
////    src[0].x = ptTopLeft.x;
////    src[0].y = ptTopLeft.y;
////    src[1].x = ptTopRight.x;
////    src[1].y = ptTopRight.y;
////    src[2].x = ptBottomRight.x;
////    src[2].y = ptBottomRight.y;
////    src[3].x = ptBottomLeft.x;
////    src[3].y = ptBottomLeft.y;
////
////    dst[0].x = 0;
////    dst[0].y = 0;
////    dst[1].x = maxWidth - 1;
////    dst[1].y = 0;
////    dst[2].x = maxWidth - 1;
////    dst[2].y = maxHeight - 1;
////    dst[3].x = 0;
////    dst[3].y = maxHeight - 1;
////
////    cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC4);
////    cv::Mat original = [BLOpenCVHelper cvMatFromUIImage:_editorImg];
////
////    cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
////
////
////    UIImage *img = nil;
////    //判断图片方向
////    if (_rotateSlider == 0.5f||_rotateSlider == -1.5) {
////        img =  [UIImage imageWithCGImage:[BLOpenCVHelper UIImageFromCVMat:undistorted].CGImage scale:1 orientation:UIImageOrientationRight];
////    }else if(std::abs(_rotateSlider) == 1.f||_rotateSlider==-3){
////        img = [UIImage imageWithCGImage:[BLOpenCVHelper UIImageFromCVMat:undistorted].CGImage scale:1 orientation:UIImageOrientationDown];
////    }else if (_rotateSlider == -0.5 || _rotateSlider == -2.5){
////        img =[UIImage imageWithCGImage:[BLOpenCVHelper UIImageFromCVMat:undistorted].CGImage scale:1 orientation:UIImageOrientationLeft];
////    }else{
////        img = [UIImage imageWithCGImage:[BLOpenCVHelper UIImageFromCVMat:undistorted].CGImage scale:1 orientation:UIImageOrientationUp];
////    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
- (MADCropScaleView *)cropScaleView
{
    if (!_cropScaleView) {
        _cropScaleView = [[MADCropScaleView alloc] initWithFrame:self.view.bounds];
    }
    return _cropScaleView;
}

- (UIButton *)finishBtn
{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.backgroundColor = kBaseColor;
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _finishBtn.layer.cornerRadius = 35/2;
        _finishBtn.layer.masksToBounds = YES;
        [_finishBtn addTarget:self action:@selector(onActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = kBaseColor;
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _backBtn.layer.cornerRadius = 35/2;
        _backBtn.layer.masksToBounds = YES;
        [_backBtn addTarget:self action:@selector(onActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


//- (UIImage *) cropImage:(NSArray *)pointArr {
//
//    CGRect rect = CGRectZero;
//    rect.size = _cropImage.size;
//
//    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
//
//    [[UIColor blackColor] setFill];
//    UIRectFill(rect);
//    [[UIColor whiteColor] setFill];
//
//    UIBezierPath *aPath = [UIBezierPath bezierPath];
//
//    //起点
//    NSValue * v = pointArr[0];
//    CGPoint p = [v CGPointValue];
//    CGPoint m_p = [self convertCGPoint:p fromRect1:self.view.frame.size toRect2:self.view.frame.size];
//    [aPath moveToPoint:m_p];
//
//    //其他点
//    for (int i = 1; i< pointArr.count; i++) {
//        NSValue * v1 = pointArr[i];
//        CGPoint p1 = [v1 CGPointValue];
//        CGPoint m_p = [self convertCGPoint:p1 fromRect1:_cropImage.size toRect2:_cropImage.size];
//        [aPath addLineToPoint:m_p];
//    }
//
//    [aPath closePath];
//    [aPath fill];
//
//    //遮罩层
//    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
//
//    CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
//    [_cropImage drawAtPoint:CGPointZero];
//
//    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return maskedImage;
//}

- (NSMutableArray *)tranP:(NSArray *)pointArr
{
    NSMutableArray *result = [NSMutableArray new];
    
    CGSize crpSize = _cropImage.size;
    CGSize scnSize = [[UIScreen mainScreen] bounds].size;
    
    CGFloat wScale = crpSize.width/scnSize.width;
    CGFloat hScale = crpSize.height/scnSize.height;
    
    for (id obj in pointArr) {
        
        CGPoint point = [obj CGPointValue];
        point.x *= wScale;
        point.y *= hScale;
        [result addObject:@(point)];
    }
    
    return result;
}

- (UIImage *)cropImage:(NSArray *)arr
{
    UIImage *srcImg = _cropImage;
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    //开始绘制图片
    UIGraphicsBeginImageContext(srcImg.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    //绘制Clip区域
    CGPoint p0 = [arr[0] CGPointValue];
    CGContextMoveToPoint(gc, p0.x, p0.y);
    
    for ( int i = 1; i < arr.count; i++) {
        CGPoint p1 = [arr[i] CGPointValue];
        CGContextAddLineToPoint(gc, p1.x, p1.y);
    }

    CGContextClosePath(gc);
    CGContextClip(gc);
    
    //坐标系转换
    //因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
    CGContextTranslateCTM(gc, 0, height);
    CGContextScaleCTM(gc, 1, -1);
    CGContextDrawImage(gc, CGRectMake(0, 0, width, height), [srcImg CGImage]);
    
    //结束绘画
    UIImage *destImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    return destImg;
    return [MADDector dectorImage:destImg];
}

- (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2 {
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}
 
#pragma mark - handler
- (void)onActionButton:(id)sender{
    if (sender == _backBtn) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (sender == _finishBtn) {

        if (_borderDetectFeature) {
            MADResultVC *resultVC = [MADResultVC new];
            resultVC.resultImg = _cropImage;
            [self.navigationController pushViewController:resultVC animated:YES];
            
        }else{
            MADResultVC *resultVC = [MADResultVC new];
            resultVC.resultImg =  [self cropImage:[self tranP:[_cropScaleView getPointArr]]];
            [self.navigationController pushViewController:resultVC animated:YES];
        }
    }
}


#pragma mark - Layout
- (void)updateViewConstraints
{
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    [super updateViewConstraints];
}
@end
