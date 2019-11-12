//
//  WLCropViewController.m
//  MMCamScanner
//
//  Created by mac on 09/06/15.
//  Copyright (c) 2015 ailink. All rights reserved.
//

#import "WLCropViewController.h"


#define backgroundHex @"2196f3"
#define kCameraToolBarHeight 100
#import "UIColor+HexRepresentation.h"
#import "MMCropView.h"
#import "Masonry.h"

#import "DSMagnifierView.h"

#import "WLDectV.h"

@interface WLCropViewController ()
<
UINavigationControllerDelegate
>

// 完成按钮
@property (nonatomic, strong) UIButton *finishBtn;

// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;

@property (strong, nonatomic) MMCropView *cropRect;

@property (strong, nonatomic) DSMagnifierView *magnifierView;

@end

@implementation WLCropViewController
- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UINavigationBarDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
    {
        if (viewController == self) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }else
        {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }
    
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    _initialRect = self.sourceImageView.frame;
    final_Rect = self.sourceImageView.frame;
    
    CGRect cropFrame = _sourceImageView.contentFrame;
    cropFrame.origin.y += kNAV_HEIGHT;
    _cropRect = [[MMCropView alloc] initWithFrame:cropFrame];
    [self.view addSubview:_cropRect];
    
    UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singlePan:)];
    singlePan.maximumNumberOfTouches = 1;
    [_cropRect addGestureRecognizer:singlePan];
    
    [self.view bringSubviewToFront:_cropRect];

    
    [self backBtn];
    [self finishBtn];
    
    if ([self isInitPoint]) {
        NSLog(@"########### cropViewController detectEdgs #########");
        [WLDectV detectEdgesImage:_sourceImageView.image targetSize:_cropRect.frame.size comBlock:^(NSMutableDictionary * _Nonnull sortedPoints) {
            
            CGPoint topLeft = [WLDectV pValue:sortedPoints idx:0];
            [_cropRect topLeftCornerToCGPoint:topLeft];
            
            CGPoint topRight = [WLDectV pValue:sortedPoints idx:1];
            [_cropRect topRightCornerToCGPoint:topRight];
            
            CGPoint bottomRight = [WLDectV pValue:sortedPoints idx:2];
            [_cropRect bottomRightCornerToCGPoint:bottomRight];
            
            CGPoint bottomLeft = [WLDectV pValue:sortedPoints idx:3];
            [_cropRect bottomLeftCornerToCGPoint:bottomLeft];
            
        }];
    }else{
        [self initEdgs];
    }
}


- (BOOL)isInitPoint{
    return (
         (_detectFeature.topLeft.x == 0 && _detectFeature.topLeft.y == 0) &&
         (_detectFeature.topRight.x == 0 && _detectFeature.topRight.y == 0) &&
         (_detectFeature.bottomRight.x == 0 && _detectFeature.bottomRight.y == 0) &&
         (_detectFeature.bottomLeft.x == 0 && _detectFeature.bottomLeft.y == 0)
    );
}

- (void)initEdgs{
    
    CGSize _srcSize = _cropRect.frame.size;
    if (_srcSize.width == 0 || _srcSize.height == 0) return;
    
    CGPoint topLeft = [WLDectV tranImgPoint:_detectFeature.topLeft imgSize:_orgSize srcSize:_srcSize];
    [_cropRect topLeftCornerToCGPoint:topLeft];
    
    CGPoint topRight = [WLDectV tranImgPoint:_detectFeature.topRight imgSize:_orgSize srcSize:_srcSize];
    [_cropRect topRightCornerToCGPoint:topRight];
    
    CGPoint bottomRight = [WLDectV tranImgPoint:_detectFeature.bottomRight imgSize:_orgSize srcSize:_srcSize];
    [_cropRect bottomRightCornerToCGPoint:bottomRight];
    
    CGPoint bottomLeft = [WLDectV tranImgPoint:_detectFeature.bottomLeft imgSize:_orgSize srcSize:_srcSize];
    [_cropRect bottomLeftCornerToCGPoint:bottomLeft];
}

- (void)singlePan:(UIPanGestureRecognizer *)gesture{
    CGPoint posInStretch = [gesture locationInView:_cropRect];
 
    if(gesture.state==UIGestureRecognizerStateBegan){
        [_cropRect findPointAtLocation:posInStretch];
    }
    if(gesture.state==UIGestureRecognizerStateEnded){
        _cropRect.activePoint.backgroundColor = [UIColor grayColor];
        _cropRect.activePoint = nil;
        [_cropRect checkangle:0];
        
        [self removeLargeView];
    }else{
        [self loadLargeView:posInStretch];
    }
    [_cropRect moveActivePointToLocation:posInStretch];
}

- (void)loadLargeView:(CGPoint)point{
    
    CGPoint size = _cropRect.frame.origin;
    
    point.x += size.x;
    point.y += size.y;
    
    //window的hidden默认为YES
    self.magnifierView.hidden = NO;
    
    //设置magnifierView的frame
    self.magnifierView.frame = CGRectMake(0, 0, 100, 100);
    self.magnifierView.center = point;
    
    self.magnifierView.layer.masksToBounds = YES;
    self.magnifierView.layer.cornerRadius = 50;
    
    //设置渲染的中心点  
    self.magnifierView.renderPoint = point;
}

- (void)removeLargeView{
    //用完一定要记得置nil。
    self.magnifierView = nil;
}

- (DSMagnifierView *)magnifierView {
    if (nil == _magnifierView) {
        _magnifierView = [[DSMagnifierView alloc] init];
        _magnifierView.renderView = self.view.window;
    }
    return _magnifierView;
}


 
- (void)cropAction:(id)sender {
    
    if([_cropRect frameEdited]){
        
        if ([self.cropdelegate respondsToSelector:@selector(didFinishCropping:from:)]) {
            [WLDectV cropAction:_sourceImageView cropV:_cropRect ajustImg:_adjustedImage];
            [self.cropdelegate didFinishCropping:_sourceImageView.image from:self];
        }
    }
    else{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MMCamScanner" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
   
}


////Image Processing
//-(UIImage *)grayImage:(UIImage *)processedImage{
//    cv::Mat grayImage = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
//
//    cv::GaussianBlur(grayImage, grayImage, cvSize(11,11), 0);
//    cv::adaptiveThreshold(grayImage, grayImage, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
//
//    UIImage *grayeditImage=[MMOpenCVHelper UIImageFromCVMat:grayImage];
//     grayImage.release();
//
//    return grayeditImage;
//
//}
//
//-(UIImage *)magicColor:(UIImage *)processedImage{
//    cv::Mat  original = [MMOpenCVHelper cvMatFromAdjustedUIImage:processedImage];
//
//    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
//
//    original.convertTo(new_image, -1, 1.9, -80);
//
//    original.release();
//    UIImage *magicColorImage=[MMOpenCVHelper UIImageFromCVMat:new_image];
//    new_image.release();
//    return magicColorImage;
//
//
//}
//
//-(UIImage *)blackandWhite:(UIImage *)processedImage{
//    cv::Mat original = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
//
//    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
//
//    original.convertTo(new_image, -1, 1.4, -50);
//    original.release();
//
//    UIImage *blackWhiteImage=[MMOpenCVHelper UIImageFromCVMat:new_image];
//    new_image.release();
//
//
//
//    return blackWhiteImage;
//
//}

- (void)dismissAction:(id)sender {
//   [self.cropdelegate didFinishCropping:[UIImage imageWithData:UIImageJPEGRepresentation(_sourceImageView.image, 0.0)] from:self];
    [self closeWithCompletion:^{
        ;
    }];

//    NSLog(@"%d",UIImagePNGRepresentation(_sourceImageView.image).length);
//    NSLog(@"Size of Image %d",UIImageJPEGRepresentation(_sourceImageView.image, 0.5).length);
}

#pragma mark CLOSE
- (void) closeWithCompletion:(void (^)(void))completion {
    
    // Need alpha 0.0 before dismissing otherwise sticks out on dismissal
    [self dismissViewControllerAnimated:YES completion:^{

        completion();
        self->_sourceImageView=nil;
        self->_adjustedImage=nil;
        self->_cropRect=nil;
        [self removeFromParentViewController];
        
    }];
}

#pragma mark Animate
- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise
{
    CGFloat arg = _rotateSlider*M_PI;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, 0*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, 0*M_PI, 1, 0, 0);
    
    return transform;
}

- (void)rotateStateDidChange
{
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    
    CGFloat arg = _rotateSlider*M_PI;
    CGFloat Wnew = fabs(_initialRect.size.width * cos(arg)) + fabs(_initialRect.size.height * sin(arg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(arg)) + fabs(_initialRect.size.height * cos(arg));
    
    CGFloat Rw = final_Rect.size.width / Wnew;
    CGFloat Rh = final_Rect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 1;
    transform = CATransform3DScale(transform, scale, scale, 1);
    _sourceImageView.layer.transform = transform;
    _cropRect.layer.transform = transform;
   
//    NSLog(@"%@",_sourceImageView);
}


- (UIButton *)finishBtn
{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_finishBtn];
        
        _finishBtn.backgroundColor = kBaseColor;
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_finishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _finishBtn.layer.cornerRadius = 35/2;
        _finishBtn.layer.masksToBounds = YES;
        [_finishBtn addTarget:self action:@selector(cropAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(-30);
            make.size.mas_equalTo(CGSizeMake(65, 35));
        }];
    }
    return _finishBtn;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_backBtn];

        
        _backBtn.backgroundColor = kBaseColor;
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        _backBtn.layer.cornerRadius = 35/2;
        _backBtn.layer.masksToBounds = YES;
        [_backBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(20);
            make.bottom.mas_equalTo(-30);
            make.size.mas_equalTo(CGSizeMake(65, 35));
        }];
        
     
    }
    return _backBtn;
}

- (UIImageView *)sourceImageView{
    if (!_sourceImageView) {
        _sourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         kNAV_HEIGHT,
                                                                         kSCREEN_WIDTH,
                                                                         kSCREEN_HEIGHT-kCameraToolBarHeight-kNAV_HEIGHT-kBOTTOM_H)];
        [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_sourceImageView setImage:_adjustedImage];
        
        _sourceImageView.clipsToBounds = YES;
        [self.view addSubview:_sourceImageView];
    }
    return _sourceImageView;
}

@end

