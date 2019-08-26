//
//  ViewController.m
//  DectorRect
//
//  Created by mac on 2017/10/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WLRootVC.h"

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "WLResultVC.h"
#import "WLCropViewController.h"
#import "WLCameraCaptureController.h"

@interface WLRootVC ()
<
WKUIDelegate,
WKNavigationDelegate,
WKScriptMessageHandler,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
MMCropDelegate
>

@property (nonatomic, strong) WKWebView *wkView;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation WLRootVC

#pragma mark --
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callBackPhoto:)
                                                 name:CJTP
                                               object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    
    if (![_destionUrl isKindOfClass:[NSString class]] || !_destionUrl.length) {
        [self loadLocalHtml];
    }else{
        [self loadServiceHtml];
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadLocalHtml{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //加载本地html文件
    [self.wkView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)loadServiceHtml{
    [self.wkView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_destionUrl]]];
}


#pragma mark --
#pragma mark logic method JS和原生交互的接口
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


/**
 把识别的图片回传到h5

 @param notify 带图片信息的通知
 */
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
}


/**
 下载图片

 @param imageUrl 图片的URL
 */
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


/**
 图片保存到相册的回调

 @param image 图片
 @param error 出错信息
 @param contextInfo 上下文环境
 */
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if(error) {
        //保存失败
    }else{
        //保存成功
    }
}


/**
 拍照
 */
- (void)takePhoto{
    NSUInteger sourceType = UIImagePickerControllerSourceTypeCamera;
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self dealPhoto:sourceType];
    }else{
        [self alertMsg:@"没有拍照权限"];
    }
}


/**
 从相册选择图片
 */
- (void)choosePhotoLibrary{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self dealPhoto:sourceType];
    }else{
        [self alertMsg:@"没有获取相册权限"];
    }
}


/**
 使用图片/相册

 @param sourceType 资源类型
 */
- (void)dealPhoto:(NSUInteger)sourceType{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self; //设置代理
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}



/**
 弹框提示：只带确定按钮

 @param msg 提示的内容
 */
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
        WLCropViewController *crop = [WLCropViewController new];
        crop.adjustedImage = image;
        crop.cropdelegate = self;
        [self presentViewController:crop animated:YES completion:nil];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark  --
#pragma mark  crop delegate
- (void)didFinishCropping:(UIImage *)finalCropImage from:(WLCropViewController *)cropObj{
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
#pragma mark lazy load
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
        
        CGRect frame = CGRectMake(0, kNAV_HEIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT - kNAV_HEIGHT - kBOTTOM_H);
        _wkView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        _wkView.UIDelegate = self;
        _wkView.navigationDelegate = self;

        _wkView.allowsBackForwardNavigationGestures = YES;
        
        [self.view addSubview:_wkView];
    }
    return _wkView;
}

@end
