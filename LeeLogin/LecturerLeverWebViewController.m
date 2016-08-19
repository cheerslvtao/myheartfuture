//
//  LecturerLeverWebViewController.m
//  LeeLogin
//
//  Created by 吕涛 on 16/8/16.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "LecturerLeverWebViewController.h"
#import <WebKit/WebKit.h>

@interface LecturerLeverWebViewController ()<WKUIDelegate,WKNavigationDelegate>
{
    UIProgressView * _progress;
    WKWebView * web;
}
@end

@implementation LecturerLeverWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.titleString;

    __weak typeof(self) weakSelf = self;

    [HTTPURL postRequest:LINK_URL(@"/userTeach/findTeachLevel") parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        weakSelf.isLecturer = [NSString stringWithFormat:@"%@",responseObject[@"success"]] ;
        if ([weakSelf.isLecturer isEqualToString:@"1"]) {
            weakSelf.urlString =  LINK_URL(@"/lecturer/lecturerInfo");
        }else {
            weakSelf.urlString = LINK_URL(@"/lecturer/unLecturer");
        }
        
        [weakSelf progressView];
        [weakSelf createWebView];

    } filure:^(NSURLSessionDataTask *task, id error) {
        
    }showHUD:NO sucessMsg:@"" failureMsg:@""];
}

-(void)createWebView{
    
    web  =[[WKWebView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, SCREEN_height-64)];
    web.UIDelegate = self;
    web.navigationDelegate = self;
    
    [web addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];

    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [web loadRequest:request];
    [self.view addSubview:web];
    [self.view insertSubview:_progress aboveSubview:web];
}
-(void)progressView{
    _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, 5)];
    _progress.progressTintColor = [UIColor greenColor];
    _progress.trackTintColor = [UIColor redColor];
    [self.view addSubview:_progress];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [_progress setProgress:web.estimatedProgress animated:YES];
        if (_progress.progress == 1) {
            [UIView animateWithDuration:1 animations:^{
                [_progress removeFromSuperview];
            }];

        }
    }
}

#pragma mark ==  navigationDelegate
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{

}

#pragma mark == 移除观察者
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
