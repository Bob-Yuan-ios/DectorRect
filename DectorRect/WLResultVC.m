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

@interface WLResultVC ()

@property (nonatomic, strong) UIImageView *showResult;

// 完成按钮
@property (nonatomic, strong) UIButton *finishBtn;

// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;


@end

@implementation WLResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_resultImg) {
        self.showResult.image = _resultImg;

    }
 
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.finishBtn];
}
 
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)completeAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:CJTP object:_resultImg];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tapAction{
    STPhotoBroswer *_broswer = [[STPhotoBroswer alloc] initWithImageArray:@[_resultImg] currentIndex:0];
    [_broswer show];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
 

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
        make.bottom.mas_equalTo(-40);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-40);
        make.size.mas_equalTo(CGSizeMake(65, 35));
    }];
    [super updateViewConstraints];
}


@end
