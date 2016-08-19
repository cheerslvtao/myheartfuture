
//
//  ResetPasswordVC.m
//  LeeLogin
//
//  Created by 李雪虎 on 16/7/28.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "ResetPasswordVC.h"
#import "LoginVC.h"//登录
#define resetPWD @"/userAccount/setLoginPwd"
@interface ResetPasswordVC ()<UITextFieldDelegate>

@end

@implementation ResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //重置密码
    self.title = @"重置密码";
    self.view.backgroundColor = BGCOLOR;
    [self addView];//添加视图
    // Do any additional setup after loading the view.
}
- (void)addView
{
    NSArray *array = @[@"  新密码",@" 确认新密码"];
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
    UIButton *button = [LeeAllView BigButton:CGRectMake(15, 240, SCREEN_width-30, 50) withTitel:@"重置密码"];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)buttonClick
{
    NSLog(@"发送重置密码");
    UITextField *newPWD = [self.view viewWithTag:11];
    UITextField *PWDtext = [self.view viewWithTag:10];
        if (PWDtext.text == newPWD.text) {
            NSLog(@"密码相同");
            [self httpRquest];//发送请求
        }else{
            [self promptViewmessage:@"密码不相同 请从新输入" sureBlock:^{
                PWDtext.text = @"";
            }];
        }
    
}
#pragma mark--网络请求
-(void)httpRquest
{
    //发送重置密码
    UITextField *pwdText =[self.view viewWithTag:10];
    ResetPasswordVC *resetPasswordVC = self;
    [HTTPURL postRequest:LINK_BASE_URL(resetPWD) parameters:@{@"veCode":VE_CODE,@"pwd":pwdText.text,@"access_token":ACCESS_TOKEN} success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject[@"success"] stringValue]isEqualToString:@"1"]){
            //提示框
            [resetPasswordVC promptViewmessage:responseObject[@"mag"] sureBlock:^{
                //跳转登录页面
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    } filure:^(NSURLSessionDataTask *task, id error) {
        [resetPasswordVC promptViewmessage:@"网络失败" sureBlock:^{
        }];
    } showHUD:YES sucessMsg:@"修改成功" failureMsg:@"修改失败"];
}
#pragma mark--提示框
-(void)promptViewmessage:(NSString *)message sureBlock:(void(^)())sureBlock
{
    UIAlertController * alert= [UICommonView showOneAlertWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确实" sureBlock:^{
        sureBlock();
    }];
    [self presentViewController:alert animated:YES completion:nil];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
   
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
