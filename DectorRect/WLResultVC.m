//
//  WLResultVC.m
//  DectorRect
//
//  Created by mac on 2019/7/30.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "WLResultVC.h"
#import "Masonry.h"
#import "STPhotoBroswer.h"
#import "UIImageView+ContentFrame.h"


@interface WLResultVC ()
<
UINavigationControllerDelegate
>
    
@property (nonatomic, strong) UIImageView *showResult;

// 完成按钮
@property (nonatomic, strong) UIButton *finishBtn;

// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;


@end

@implementation WLResultVC

#pragma mark --
#pragma mark UINavigationBarDelegate
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

#pragma mark --
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    
    if (_resultImg) {
        self.showResult.image = _resultImg;
    }
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.finishBtn];
}
 
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark --
#pragma mark btnAction
/**
 取消
 */
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 完成
 */
- (void)completeAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:CJTP object:_resultImg];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 预览图片
 */
- (void)tapAction{
    STPhotoBroswer *_broswer = [[STPhotoBroswer alloc] initWithImageArray:@[_resultImg] currentIndex:0];
    [_broswer show];
}


#pragma mark --
#pragma mark lazy load
- (UIImageView *)showResult
{
    if (!_showResult) {
        _showResult = [UIImageView new];
        [self.view addSubview:_showResult];
        
        [_showResult setUserInteractionEnabled:YES];
        [_showResult setContentMode:UIViewContentModeScaleAspectFill];
                
        CGFloat width = _resultImg.size.width/3.0;
        CGFloat height = _resultImg.size.height/3.0;
        CGFloat sWidth = self.view.frame.size.width;
        [_showResult  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            if (width > sWidth) {
                make.width.mas_equalTo(@(sWidth));
                make.height.mas_equalTo(@(height/width * sWidth));
            }else{
                make.width.mas_equalTo(@(width));
                make.height.mas_equalTo(@(height));
            }
        }];
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_showResult addGestureRecognizer:ges];
    }
    return _showResult;
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
        [_finishBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
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
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


#pragma mark - Layout
- (void)updateViewConstraints
{
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-30);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-30);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    [super updateViewConstraints];
}


@end
