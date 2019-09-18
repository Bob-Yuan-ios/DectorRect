//
//  WLResetUrlVC.m
//  DectorRect
//
//  Created by mac on 2019/9/4.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import "WLResetUrlVC.h"
#import <Masonry.h>

#import "WLRootVC.h"


@interface WLResetUrlVC ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *tipLbl;

@property (nonatomic, strong) UITextField *urlTF;

@property (nonatomic, strong) UIButton *sureBtn;

@end

@implementation WLResetUrlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tipLbl.text = @"请输入需要验证的网址";
    self.urlTF.text = @"http://";
    [self.sureBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)submit{
    if (_urlTF.text.length < 8) {
        WLRootVC *vc = [[WLRootVC alloc] init];
        vc.destionUrl = nil;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    WLRootVC *vc = [[WLRootVC alloc] init];
    vc.destionUrl = self.urlTF.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UILabel *)tipLbl{
    if (!_tipLbl) {
        _tipLbl = [UILabel new];
        [self.view addSubview:_tipLbl];
        
        [_tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(100));
            make.left.mas_equalTo(@(40));
            make.right.mas_equalTo(@(-40));
        }];
    }
    return _tipLbl;
}

- (UITextField *)urlTF{
    if (!_urlTF) {
        _urlTF = [UITextField new];
        [self.view addSubview:_urlTF];
        
        _urlTF.borderStyle = UITextBorderStyleBezel;
        
        [_urlTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipLbl.mas_bottom).offset(12);
            make.left.mas_equalTo(@(40));
            make.right.mas_equalTo(@(-40));
            make.height.equalTo(@(40));
        }];
    }
    return _urlTF;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_sureBtn];
        
        _sureBtn.backgroundColor = [UIColor blueColor];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        
        [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.urlTF.mas_bottom).offset(40);
            make.left.width.height.equalTo(self.urlTF);
        }];
    }
    return _sureBtn;
}

@end
