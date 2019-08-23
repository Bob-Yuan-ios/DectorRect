//
//  ViewController.m
//  DectorRect
//
//  Created by mac on 2017/10/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "WLCameraCaptureController.h"
 
#import "WLResultVC.h"
#import "WLPhotoVC.h"

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "CropViewController.h"

@interface ViewController ()
<
WKUIDelegate,
WKNavigationDelegate,
WKScriptMessageHandler,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
MMCropDelegate
>

@property (nonatomic, strong) WKWebView *wkView;

@property(nonatomic,strong) UIImagePickerController *imagePicker; //声明全局的UIImagePickerController

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callBackPhoto:) name:CJTP object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadLocalHtml];
    
//    [self loadServiceHtml];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [_wkView.configuration.userContentController addScriptMessageHandler:self  name:SB];
    [_wkView.configuration.userContentController addScriptMessageHandler:self  name:XC];
    [_wkView.configuration.userContentController addScriptMessageHandler:self  name:PZ];
    [_wkView.configuration.userContentController addScriptMessageHandler:self  name:SC];
    [_wkView.configuration.userContentController addScriptMessageHandler:self  name:XZ];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [_wkView.configuration.userContentController removeScriptMessageHandlerForName:SB];
    [_wkView.configuration.userContentController removeScriptMessageHandlerForName:XC];
    [_wkView.configuration.userContentController removeScriptMessageHandlerForName:PZ];
    [_wkView.configuration.userContentController removeScriptMessageHandlerForName:SC];
    [_wkView.configuration.userContentController removeScriptMessageHandlerForName:XZ];
}

- (void)loadLocalHtml{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //加载本地html文件
    [self.wkView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)loadServiceHtml{
        [self.wkView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVICEURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
    id parameter = message.body;
    
    //JS调用OC
    NSString *method = message.name;
    if([method isEqualToString:SB]){
        //拍照识别
        WLCameraCaptureController *vc = [[WLCameraCaptureController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
     }else if([method isEqualToString:XZ]){
         //图片下载
//         WLResultVC *vc = [[WLResultVC alloc] init];
//         vc.downUrl = parameter;
//         [self.navigationController pushViewController:vc animated:YESp];
         
         [self downloadImage:parameter];
     }else if([method isEqualToString:PZ]){
         //拍照识别
         WLCameraCaptureController *vc = [[WLCameraCaptureController alloc] init];
         [self.navigationController pushViewController:vc animated:YES];
         
     }else if([method isEqualToString:XC]){
         //相册
         [self choosePhotoLibrary];
     }
}

- (void)callBackPhoto:(NSNotification *)notify{
    
    UIImage *img = notify.object;
    NSData *data = UIImageJPEGRepresentation(img, 0.5f);
    
    NSString *imgCon = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *imgStr = [NSString stringWithFormat:@"data:image/jpg;base64,%@",imgCon];
    
    NSString *imgName = [NSString stringWithFormat:@"%.lf.jpg",[[NSDate date] timeIntervalSince1970]];
    
    NSDictionary *dic = @{@"img":imgStr,@"name":imgName};
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *jsStr = [NSString stringWithFormat:@"javascript:%@(%@)",SC,jsonString];
    [self.wkView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSString *errMsg = error.userInfo.description;
        NSString *message = errMsg.length ? errMsg : @"提交成功";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
 
//    //以二进制数据的形式加载沙箱中的文件，
//    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
//
//    NSString *strJs=[NSString stringWithFormat:@"document.images[0].src='%@'",imageSource];
//    [_wkView evaluateJavaScript:strJs completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"webView response: %@ error: %@", response, error);
//    }];
}

// 图片转成base64字符串需要先取出所有空格和换行符
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

- (void)downloadImage:(NSString *)imageUrl{
    if (![imageUrl isKindOfClass:[NSString class]] || !imageUrl.length) {
        return;
    }
    
    //通过一个异步执行的全局并发队列，开启了一个子线程进行图片下载
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        //子线程下载图片
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        //将网络数据初始化为UIImage对象
        UIImage *image = [UIImage imageWithData:data];
        if(image!=nil){
            //回到主线程设置图片，更新UI界面
            dispatch_async(dispatch_get_main_queue(),^{
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               @selector(image:didFinishSavingWithError:contextInfo:),
                                               nil);
                
            });
        }
        else{
            NSLog(@"图片下载出现错误");
        }
    });
}


- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if(error) {
        //保存失败
        
    }else{
        //保存成功
        
    }
}


- (void)takePhoto{
    NSUInteger sourceType = UIImagePickerControllerSourceTypeCamera;
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self dealPhoto:sourceType];
    }else{
        [self alertMsg:@"没有拍照权限"];
    }
}

- (void)choosePhotoLibrary{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self dealPhoto:sourceType];
    }else{
        [self alertMsg:@"没有获取相册权限"];
    }
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

#pragma mark --
#pragma mark imageDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //通过key值获取到图片
        CropViewController *crop = [CropViewController new];
        //[self.storyboard instantiateViewControllerWithIdentifier:@"crop"];
//        crop.cropdelegate=self;
//        ripple=[[RippleAnimation alloc] init];
//        crop.transitioningDelegate=ripple;
//        ripple.touchPoint=self.cameraBut.frame;
//        
        crop.adjustedImage = image;
        crop.cropdelegate = self;
        [self presentViewController:crop animated:YES completion:nil];
    }];
    
}

//当用户取消选择的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark crop delegate
- (void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj{
    [cropObj closeWithCompletion:^{
        //        ripple=nil;
    }];
    //    [self uploadData:finalCropImage];
    NSLog(@"Size of Image %lu",(unsigned long)UIImageJPEGRepresentation(finalCropImage, 0.5).length);
    //    NSLog(@"%@ Image",finalCropImage);
    /*OCR Call*/
    //     [self OCR:finalCropImage];
    
    WLResultVC *resultVC = [WLResultVC new];
    resultVC.resultImg = finalCropImage;
    [self.navigationController pushViewController:resultVC animated:YES];
}



#pragma mark --
#pragma mark 系统相机获取的图片大于2M会自动旋转
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (WKWebView *)wkView{
    if (!_wkView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        config.preferences = preferences;

        
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        config.userContentController = wkUController;
        
        _wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _wkView.UIDelegate = self;
        _wkView.navigationDelegate = self;

        _wkView.allowsBackForwardNavigationGestures = YES;

        [self.view addSubview:_wkView];
    }
    return _wkView;
}

@end
