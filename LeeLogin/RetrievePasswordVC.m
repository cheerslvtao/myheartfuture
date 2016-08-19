

//
//  RetrievePasswordVC.m
//  LeeLogin
//
//  Created by 李雪虎 on 16/7/28.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "RetrievePasswordVC.h"
#import "ResetPasswordVC.h"//重置密码
#define GetPwdEmail @"/userAccount/sendGetPwdEmail"
@interface RetrievePasswordVC ()<UITextFieldDelegate>

@end

@implementation RetrievePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    self.view.backgroundColor = BGCOLOR;
    [self addView];//添加视图
    // Do any additional setup after loading the view.
}
- (void)addView
{
    NSArray *array = @[@"  VE号",@"  注册邮箱"];
    LeeAllView *leeAllView = [LeeAllView new];
    for (int i=0; i<2; i++)
    {
        UIView *view = [leeAllView registeredViewWithFrame:CGRectMake(15, 85+(65*i), SCREEN_width-30, 50)];
        leeAllView.titerLabel.text = array[i];
        leeAllView.textField.tag = i+10;
        leeAllView.textField.delegate = self;
        [self.view addSubview:view];
    }
    //发送重置邮件按钮
    UIButton *button = [LeeAllView BigButton:CGRectMake(15, 240, SCREEN_width-30, 50) withTitel:@"发送重置邮件"];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)buttonClick
{
    NSLog(@"发送重置邮件");
    UITextField *veText = [self.view viewWithTag:10];//ve
    UITextField *emailText = [self.view viewWithTag:11];
    if ([veText.text isEqualToString:@""]||[emailText.text isEqualToString:@""]) {
        [self promptViewmessage:@"请完善信息" sureBlock:^{
            
        }];
    }else{
       __weak RetrievePasswordVC *retrievePasswordVC = self;
        
        [HTTPURL postRequest:LINK_BASE_URL(GetPwdEmail) parameters:@{@"email":emailText.text} success:^(NSURLSessionDataTask *task, id responseObject) {
            [retrievePasswordVC promptViewmessage:responseObject[@"mag"] sureBlock:^{
                //成功
                if ([[responseObject[@"success"] stringValue]isEqualToString:@"1"]) {
                    //提示框
                    [retrievePasswordVC promptViewmessage:responseObject[@"mag"] sureBlock:^{
                        //跳转
                        ResetPasswordVC *resetPassword = [ResetPasswordVC new];
                        [retrievePasswordVC.navigationController pushViewController:resetPassword animated:YES];
                    }];
                }else{
                    
                }
               
            }];
        } filure:^(NSURLSessionDataTask *task, id error) {
            //提示框
            NSLog(@"%@",error);
            [retrievePasswordVC promptViewmessage:@"网络故障" sureBlock:^{
                ResetPasswordVC *resetPassword = [ResetPasswordVC new];
                [retrievePasswordVC.navigationController pushViewController:resetPassword animated:YES];
            }];
        } showHUD:YES sucessMsg:@"发送成功" failureMsg:@"网络连接失败"];
    }
    
}
//提示框
-(void)promptViewmessage:(NSString *)message sureBlock:(void(^)())sureBlock
{
    UIAlertController * alert= [UICommonView showOneAlertWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确实" sureBlock:^{
        sureBlock();
    }];
    [self presentViewController:alert animated:YES completion:nil];
}
//收起键盘
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
{
    [self.view endEditing:YES];
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