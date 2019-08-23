//
//  MADPhotoVC.m
//  MADDocScan
//
//  Created by mac on 2019/8/2.
//  Copyright © 2019年 梁宪松. All rights reserved.
//

#import "MADPhotoVC.h"

@interface MADPhotoVC ()
<
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@property(nonatomic,strong) UIImagePickerController *imagePicker; //声明全局的UIImagePickerController


@end

@implementation MADPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (_type) {
        case PHOTO_CAMERA:
            [self takePhoto];
            break;
        case PHOTO_LIBRARY:
            [self choosePhotoLibrary];
            break;
        default:
            break;
    }
}


- (void)takePhoto{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self dealPhoto:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)choosePhotoLibrary{
    [self dealPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)dealPhoto:(NSUInteger)sourceType{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self; //设置代理
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)alertMsg:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -实现图片选择器代理-（上传图片的网络请求也是在这个方法里面进行，这里我不再介绍具体怎么上传图片）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //通过key值获取到图片
        if (self.dealPhotoBlock) {
            self.dealPhotoBlock(image);
        }
    }];
 
}

//当用户取消选择的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
