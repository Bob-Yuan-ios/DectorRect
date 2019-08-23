//
//  YSYBaseVC.m
//  DectorRect
//
//  Created by mac on 2019/8/21.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "YSYBaseVC.h"

@interface YSYBaseVC ()

@end

@implementation YSYBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)dealloc{
    NSLog(@"__function:%s__,class:%@",__func__,NSStringFromClass([self class]));
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
