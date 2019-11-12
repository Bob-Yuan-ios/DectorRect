//
//  WLCameraCaptureController.m
//  DectorRect
//
//  Created by mac on 2017/10/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WLCameraCaptureController.h"

#import "WLSnapshotButton.h"
#import "WLCameraCaptureView.h"
#import "Masonry.h"

#import "WLResultVC.h"
#import "WLCropViewController.h"

#import "MMCropView.h"

#import "WLCameraCropV.h"

@interface WLCameraCaptureController ()
<
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
MMCropDelegate
>

// 导航栏
@property (nonatomic, strong) UIView *navToolBar;
    
// 返回按钮
@property (nonatomic,strong) UIButton *leftBtn;
    
// 导航栏标题
@property (nonatomic,strong) UILabel *navTitleLabel;
    
// 闪光灯按钮
@property (nonatomic,strong) UIButton *flashLigthToggle;
    
// 拍照按钮
@property (nonatomic, strong) WLSnapshotButton *snapshotBtn;
    
// 拍照视图
@property (nonatomic, strong) WLCameraCaptureView *captureCameraView;

@property (nonatomic, strong) WLCameraCropV *cameraCropV;

// 聚焦指示器
@property (nonatomic, strong) UIView *focusIndicator;
    
// 单击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UINavigationController *nav;

@end

@implementation WLCameraCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nav = self.navigationController;

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    [self initUI];
    
    // 设置需要更新约束
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    // 关闭闪光灯
//    self.captureCameraView.enableTorch = NO;
//    // 停止捕获图像
//    [self.captureCameraView stop];
    
    self.cameraCropV.enableTorch = NO;
    [self.cameraCropV stop];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    // 开始捕获图像
//    [self.captureCameraView start];
    
    [self.cameraCropV start];
}

/**
 初始化视图
 */
- (void)initUI{
    
    // 导航栏
    [self.view addSubview:self.navToolBar];
    [self.navToolBar addSubview:self.leftBtn];
    [self.navToolBar addSubview:self.flashLigthToggle];
    [self.navToolBar addSubview:self.navTitleLabel];
    
//    // 拍照视图
//    [self.view addSubview:self.captureCameraView];
//    [self.captureCameraView setupCameraView];
//    // 添加单机手势
//    [self.captureCameraView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self.view addSubview:self.cameraCropV];
    [self.cameraCropV addGestureRecognizer:self.tapGestureRecognizer];
    [self.tapGestureRecognizer addTarget:self action:@selector(handleTapGesture:)];
    
    // 拍照按钮
    [self.view addSubview:self.snapshotBtn];
    // 添加聚焦指示器
    [self.view addSubview:self.focusIndicator];
    // 更新导航栏标题
    [self updateTitleLabel];
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


#pragma mark - engine
- (void)onFlashLigthToggle {
//    BOOL enable = !self.captureCameraView.isTorchEnabled;
//    self.captureCameraView.enableTorch = enable;
//    [self updateTitleLabel];
    
    
        BOOL enable = !self.cameraCropV.isTorchEnabled;
        self.cameraCropV.enableTorch = enable;
        [self updateTitleLabel];
}

- (void)onSnapshotBtn:(id)sender {

    __weak typeof(self) weakSelf = self;
    [self.cameraCropV completeWithBlock:^(TransformCIFeatureRect fe, UIImage *img, CGSize size) {
        __strong typeof(self) strongSelf = weakSelf;
        
        WLCropViewController *crop = [WLCropViewController new];
        crop.adjustedImage = img;
        crop.cropdelegate = strongSelf;
        crop.detectFeature = fe;
        crop.orgSize = size;
        
        [strongSelf.nav presentViewController:crop animated:YES completion:nil];
    }];
    
//    __weak typeof(self) weakSelf = self;
//#warning 适配手动裁剪
//    [self.captureCameraView captureImageWithCompletionHandler:^(UIImage *data, CIRectangleFeature *borderDetectFeature) {
////    [self.captureCameraView captureImageWithCompletionHandler:^(UIImage *data, TransformCIFeatureRect *borderDetectFeature) {
//        __strong typeof(self) strongSelf = weakSelf;
//
//        if(borderDetectFeature){
//            [strongSelf.nav popViewControllerAnimated:NO];
//
//            WLResultVC *resultVC = [[WLResultVC alloc] init];
//            resultVC.resultImg = data;
//            [strongSelf.nav pushViewController:resultVC animated:YES];
//
//        }else{
//            WLCropViewController *crop = [WLCropViewController new];
//            crop.adjustedImage = data;
//            crop.cropdelegate = self;
//            [strongSelf.nav presentViewController:crop animated:YES completion:nil];
//        }
//    }];
    
//#warning 适配手动裁剪
//    __weak typeof(self) weakSelf = self;
//    [self.captureCameraView captureImageWithCompletionHandler:^(UIImage *data, TransformCIFeatureRect *borderDetectFeature) {
//        __strong typeof(self) strongSelf = weakSelf;
//
//        WLCropViewController *crop = [WLCropViewController new];
//        crop.adjustedImage = data;
//        crop.cropdelegate = strongSelf;
//        crop.detectFeature = borderDetectFeature;
//        [strongSelf.nav presentViewController:crop animated:YES completion:nil];
//
//    }];
}


#pragma mark crop delegate
- (void)didFinishCropping:(UIImage *)finalCropImage from:(WLCropViewController *)cropObj{
    [cropObj closeWithCompletion:^{
        //        ripple=nil;
    }];
    //    [self uploadData:finalCropImage];
    NSLog(@"Size of Image %lu",(unsigned long)UIImageJPEGRepresentation(finalCropImage, 0.5).length);
    //    NSLog(@"%@ Image",finalCropImage);
    /*OCR Call*/
    //     [self OCR:finalCropImage];
    
    [_nav popViewControllerAnimated:NO];
    
    WLResultVC *resultVC = [WLResultVC new];
    resultVC.resultImg = finalCropImage;
    [_nav pushViewController:resultVC animated:YES];
}


- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
//    if (sender.state == UIGestureRecognizerStateRecognized)
//    {
//        CGPoint location = [sender locationInView:self.view];
//        [self.captureCameraView focusAtPoint:location completionHandler:^
//         {
//             [self focusIndicatorAnimateToPoint:location];
//         }];
//        [self focusIndicatorAnimateToPoint:location];
//    }
    
    
        if (sender.state == UIGestureRecognizerStateRecognized)
        {
            CGPoint location = [sender locationInView:self.view];
            [self.cameraCropV focusAtPoint:location completionHandler:^
             {
                 [self focusIndicatorAnimateToPoint:location];
             }];
            [self focusIndicatorAnimateToPoint:location];
        }

}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.focusIndicator.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4 animations:^
          {
              self.focusIndicator.alpha = 0.0;
          }];
     }];
}

- (void)popSelf
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

// 更新
- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.5;
    [self.navTitleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    self.navTitleLabel.text = self.cameraCropV.isTorchEnabled ? @"闪光灯 开" : @"闪光灯 关";
}


#pragma mark - Getter
- (UIView *)navToolBar
{
    if (!_navToolBar) {
        _navToolBar = [[UIView alloc] init];
        _navToolBar.backgroundColor = kBaseColor;
    }
    return _navToolBar;
}

- (UIView *)focusIndicator
{
    if (!_focusIndicator) {
        _focusIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _focusIndicator.layer.borderWidth = 5.0f;
        _focusIndicator.layer.borderColor = kWhiteColor.CGColor;
        _focusIndicator.alpha = 0;
    }
    return _focusIndicator;
}



- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, 0, 40, 40);
        [_leftBtn setImage:[UIImage imageNamed:@"Capture_back_forward"] forState:UIControlStateNormal];
        [_leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_leftBtn setTitle:@"  " forState:UIControlStateNormal];
        _leftBtn.adjustsImageWhenHighlighted = NO;
        [_leftBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UILabel *)navTitleLabel
{
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc] init];
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navTitleLabel.font = [UIFont systemFontOfSize:17];
        _navTitleLabel.textColor = kWhiteColor;
    }
    return _navTitleLabel;
}

- (UIButton *)flashLigthToggle
{
    if (!_flashLigthToggle) {
        _flashLigthToggle = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashLigthToggle.frame = CGRectMake(0, 0, 40, 40);
        [_flashLigthToggle setImage:[UIImage imageNamed:@"Capture_torch"] forState:UIControlStateNormal];
        [_flashLigthToggle setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        [_flashLigthToggle setTitle:@"  " forState:UIControlStateNormal];
        _flashLigthToggle.titleLabel.font = [UIFont systemFontOfSize:17];
        _flashLigthToggle.adjustsImageWhenHighlighted = NO;
        [_flashLigthToggle addTarget:self action:@selector(onFlashLigthToggle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashLigthToggle;
}

- (WLSnapshotButton *)snapshotBtn
{
    if (!_snapshotBtn) {
        _snapshotBtn = [[WLSnapshotButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_snapshotBtn addTarget:self action:@selector(onSnapshotBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapshotBtn;
}

- (WLCameraCropV *)cameraCropV{
    if (!_cameraCropV) {
        _cameraCropV = [[WLCameraCropV alloc] initWithFrame:self.view.bounds];
        _cameraCropV.backgroundColor = kBlackColor;
    }
    
    return _cameraCropV;
}

- (WLCameraCaptureView *)captureCameraView
{
    if (!_captureCameraView) {
        _captureCameraView = [[WLCameraCaptureView alloc] initWithFrame:self.view.bounds];
        //打开边缘检测
        [_captureCameraView setEnableBorderDetection:YES];
        _captureCameraView.backgroundColor = kBlackColor;
    }
    return _captureCameraView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
      //_tapGestureRecognizer.delegate = self;
    }
    return _tapGestureRecognizer;
}

#pragma mark - Contraints
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [_navToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kSTATUS_H);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44 + 10);
    }];
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self->_navToolBar);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [_flashLigthToggle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self->_navToolBar);
        make.size.mas_equalTo(self->_leftBtn.frame.size);
    }];
    
    [_navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self->_navToolBar);
    }];
    
    [_snapshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(65, 65));
        make.bottom.mas_equalTo(-25 - kBOTTOM_H);
        make.centerX.mas_equalTo(self.view);
    }];
    
//    [_captureCameraView mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.left.right.mas_equalTo(0);
//        make.top.mas_equalTo(self->_navToolBar.mas_bottom);
//        make.bottom.mas_equalTo(0 - kBOTTOM_H);
//    }];
    
    
    [_cameraCropV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self->_navToolBar.mas_bottom);
        make.bottom.mas_equalTo(0 - kBOTTOM_H);
    }];
}
@end
