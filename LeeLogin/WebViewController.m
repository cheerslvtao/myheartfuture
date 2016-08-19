//
//  WebViewController.m
//  LeeLogin
//
//  Created by 吕涛 on 16/8/15.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
@interface WebViewController ()<WKUIDelegate,WKNavigationDelegate>
{
    UIProgressView * _progress;
    WKWebView * web;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
//    self.title = self.titleString;
    
    [self progressView];
    [self createWebView];
    
}

-(void)createWebView{
    
    web  =[[WKWebView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, SCREEN_height-64)];
    web.UIDelegate = self;
    web.navigationDelegate =self;
    web.allowsBackForwardNavigationGestures = YES;
    [web addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [web loadRequest:request];
    [self.view addSubview:web];
    [self.view insertSubview:_progress aboveSubview:web]; //把progress 放到  web 的上面

}
//添加进度条
-(void)progressView{
    _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 65, SCREEN_width, 1)];
    _progress.backgroundColor = [UIColor redColor];
    [self.view addSubview:_progress];
}
//进度条的方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [_progress setProgress:web.estimatedProgress animated:YES];
        if (web.estimatedProgress == 1) {
            [UIView animateWithDuration:0.5 animations:^{
                [_progress removeFromSuperview];
            }];
            
        }
    }
}

#pragma mark ==  navigationDelegate
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    // 以 html title 设置 导航栏 title
    __weak typeof(self) weakself= self;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        weakself.title = result;
    }];
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    NSLog(@"%@",[webView stringByEvaluatingJavaScriptFromString:@"document.title"]);

}

-(void)dealloc{
    [web removeObserver:self forKeyPath:@"estimatedProgress"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
