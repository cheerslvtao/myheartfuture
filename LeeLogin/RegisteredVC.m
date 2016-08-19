//
//  RegisteredVC.m
//  LeeLogin
//
//  Created by 李雪虎 on 16/7/27.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "RegisteredVC.h"
#import "LeeAllView.h"
#import "HomePageViewController.h"//首页
#import "RegistrationTermsVC.h"//注册条款
#import "RegistrationPromptVC.h"//注册提示
#define REGISTERED @"/userAccount/reg"//注册
#define LOGIN @"/userAccount/login"//登录
#define TJVE @"/userAccount/getNameByVeCode"//获取推荐人姓名
@interface RegisteredVC ()<UITextFieldDelegate,sendvaluedelegate>
{
    UITextField*_editingTextField;
    CGFloat keyboardHeight;
    CGFloat durationTime;
    UIScrollView *scrollView;
    BOOL lastButton;
    NSMutableArray *_tagArray;
}
@end

@implementation RegisteredVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册界面
    self.navigationController.navigationBarHidden =NO;
    self.title = @"会员注册";
    _tagArray = [[NSMutableArray alloc]init];
    self.view.backgroundColor = BGCOLOR;
    [self loadingView];//加载视图
    
    // Do any additional setup after loading the view.
}
//加载视图
-(void)loadingView
{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, SCREEN_height)];
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    scrollView.backgroundColor = [UIColor colorWithRed:244/255.0 green:245/255.0 blue:247/255.0 alpha:1];
    scrollView.contentSize = CGSizeMake(SCREEN_width, 620);
    [self.view addSubview:scrollView];
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    //给view添加一个手势监测；
    [scrollView addGestureRecognizer:singleRecognizer];
    LeeAllView *leeAllView = [LeeAllView new];
    NSArray *array = @[@"  推荐人VE",@"  推荐人",@"  昵称",@"  电话",@"  密码",@"  确认密码"];
    for (int i=0; i<array.count; i++) {
        
      UIView *view = [leeAllView registeredViewWithFrame:CGRectMake(15, 25+(65*i), SCREEN_width-30, 50)];
        leeAllView.titerLabel.text = array[i];
        leeAllView.textField.tag = view.frame.origin.y;
        leeAllView.textField.delegate = self;
        if (i==6) {
            leeAllView.textField.frame = CGRectMake(100, 0,view.frame.size.width-181, view.frame.size.height);
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.frame.size.width-90, 0, 90, view.frame.size.height)];
            [view addSubview:imgView];
            
        }
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)leeAllView.textField.tag];
        [_tagArray addObject:tagStr];
         [scrollView addSubview:view];
    }
    //对勾按钮
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(rightButton:) forControlEvents:UIControlEventTouchUpInside];
    but.frame = CGRectMake(30,430, 30, 30);
    [scrollView addSubview:but];
    UILabel *yesLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 430, 40, 30)];
    yesLabel.text = @"同意";
    yesLabel.font = THIRTEEN;
    [scrollView addSubview:yesLabel];
    //注册条款按钮
    UIButton *termsBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsBut addTarget:self action:@selector(termsButClicled) forControlEvents:UIControlEventTouchUpInside];
    [termsBut setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:220/255.0 alpha:1] forState:UIControlStateNormal];
    [termsBut setTitle:@"注册条款" forState:UIControlStateNormal];
    termsBut.titleLabel.font = THIRTEEN;//设置字体大小
    termsBut.frame = CGRectMake(110,430, 120, 30);
    [scrollView addSubview:termsBut];
    //登录按钮
    UIButton *loginBut = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBut.frame = CGRectMake(15, 480, SCREEN_width-30, 50);
    [loginBut addTarget:self action:@selector(loginButClicled) forControlEvents:UIControlEventTouchUpInside];
    loginBut.titleLabel.font = THIRTEEN;
    [loginBut setTitle:@"登  录" forState:UIControlStateNormal];
    loginBut.backgroundColor = COLOR(62, 94, 149, 1);
    //按钮编辑
    [loginBut.layer setMasksToBounds:YES];
    //边框圆角半径
    [loginBut.layer setCornerRadius:10.0];
    [scrollView addSubview:loginBut];
    
}
#pragma mark--登录按钮事件
- (void)loginButClicled
{
    UITextField *recText =[self.view viewWithTag:[[_tagArray objectAtIndex:0]intValue]];//推荐人
    UITextField *nickNameText =[self.view viewWithTag:[[_tagArray objectAtIndex:2]intValue]];//昵称
    UITextField *phoneText =[self.view viewWithTag:[[_tagArray objectAtIndex:3]intValue]];//手机号
    UITextField *pwdText =[self.view viewWithTag:[[_tagArray objectAtIndex:4]intValue]];//密码
    UITextField *confirmText =[self.view viewWithTag:[[_tagArray objectAtIndex:5]intValue]];//确认密码
    if (lastButton==1)
    {
        if ([nickNameText.text isEqualToString:@""]||[phoneText.text isEqualToString:@""]||[pwdText.text isEqualToString:@""]||[confirmText.text isEqualToString:@""]) {
            [self promptViewmessage:@"资料填写不完善 请完善资料" sureBlock:^{
                
            }];
        }else{
            
            
            if ([recText.text isEqualToString:@""]) {
                RegistrationPromptVC *PromptVC = [RegistrationPromptVC new];
                PromptVC.delegate =self;
                [self.navigationController pushViewController:PromptVC animated:YES];
                
            }else{
            //请求
           __weak typeof(self)  regist = self;

                //注册请求
                [HTTPURL postRequest:LINK_BASE_URL(REGISTERED) parameters:@{@"ve_code":recText.text,@"pwd":pwdText.text,@"IP":IP,@"nick_name":nickNameText.text,@"phone":phoneText.text} success:^(NSURLSessionDataTask *task, id responseObject) {
                    NSLog(@"%@",responseObject);
                    NSLog(@"%@",responseObject[@"success"]);
                    //正确
                    if ([[responseObject[@"success"] stringValue]isEqualToString:@"1"]) {
                        [USER_D setObject:responseObject[@"data"][@"ve_code"] forKey:@"ve_code"];
                        NSString *ve_code = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"ve_code"]];
                        //登录请求获得secret驿码
                        [HTTPURL postRequest:LINK_BASE_URL(LOGIN) parameters:@{@"ve_code":ve_code,@"pwd":pwdText.text,@"IP":IP} success:^(NSURLSessionDataTask *task, id responseObject) {
                            NSLog(@"~~~~~~~%@",responseObject);
                            NSLog(@"%@",responseObject[@"msg"]);
                            [USER_D setObject:responseObject[@"data"][@"secret"] forKey:@"secret"];//驿码
                            //跳转页面
                            if ([responseObject[@"code"] isEqualToString:@"012"]) {
                                NSLog(@"%d",[responseObject[@"code"]intValue]);
                                [HTTPURL authorizationsuccess:^(NSURLSessionDataTask *task, id responseObject) {
                                    NSLog(@"%@",responseObject);
                                    [USER_D setObject:responseObject[@"value"] forKey:@"token"];
                                    [USER_D synchronize];
                                    [USER_D setBool:lastButton forKey:@"remember"];
                                    HomePageViewController *vc = [HomePageViewController new];
                                    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                                    UIWindow *window =[[UIApplication  sharedApplication].delegate window];
                                    window.rootViewController = nvc;
                                } Success:^(NSURLSessionDataTask *task, id responseObject) {
                                    
                                }];//授权
                                
                            }else{
                                
                                UIAlertController * alert = [UICommonView showOneAlertWithTitle:@"提示" message:responseObject[@"msg"] preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确定" sureBlock:^{
                                    
                                }];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            
                        } filure:^(NSURLSessionDataTask *task, id error) {
                            
                        } showHUD:NO sucessMsg:@"" failureMsg:@""];
                        
                        HomePageViewController *vc = [HomePageViewController new];
                        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                        UIWindow *window =[[UIApplication  sharedApplication].delegate window];
                        window.rootViewController = nvc;
                    }else{
                        NSLog(@"");
                    }

                } filure:^(NSURLSessionDataTask *task, id error) {

                } showHUD:YES sucessMsg:@"注册成功" failureMsg:@"注册失败"];
                [USER_D setObject:recText.text forKey:@"referees"];//推荐人
                [USER_D setObject:phoneText.text forKey:@"phone"];//手机号
                [USER_D setObject:pwdText.text forKey:@"password"];//密码
                [USER_D setObject:nickNameText.text forKey:@"nickName"];//昵称
            }
        }
    }else{
        //提示
        [self promptViewmessage:@"请同意注册条款" sureBlock:^{
            
        }];
    }
    
}
//注册条款
-(void)termsButClicled
{
    RegistrationTermsVC *TermsVC = [RegistrationTermsVC new];
    [self.navigationController pushViewController:TermsVC animated:YES];
    NSLog(@"注册条款");
}
//发送注册请求
- (void)refresh
{
    UITextField *recText =[self.view viewWithTag:[[_tagArray objectAtIndex:0]intValue]];//推荐人
    UITextField *nickNameText =[self.view viewWithTag:[[_tagArray objectAtIndex:2]intValue]];//昵称
    UITextField *phoneText =[self.view viewWithTag:[[_tagArray objectAtIndex:3]intValue]];//手机号
    UITextField *pwdText =[self.view viewWithTag:[[_tagArray objectAtIndex:4]intValue]];//密码
    [USER_D setObject:pwdText.text forKey:@"password"];
    __weak RegisteredVC *regist = self;
    NSLog(@"%@%@%@",nickNameText.text,phoneText.text,pwdText.text);

    //注册请求
    [HTTPURL postRequest:LINK_BASE_URL(REGISTERED) parameters:@{@"ve_code":@"94272",@"pwd":pwdText.text,@"IP":@"23124",@"nick_name":nickNameText.text,@"phone":phoneText.text} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject[@"success"] stringValue] isEqualToString:@"1"])
        {
            
            [USER_D setObject:responseObject[@"data"][@"ve_code"] forKey:@"ve_code"];
            NSString *ve_code = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"ve_code"]];
            NSLog(@"%@",[USER_D objectForKey:@"ve_code"]);
            NSLog(@"%@",pwdText.text);
            //登录请求获得secret驿码
            [HTTPURL postRequest:LINK_BASE_URL(LOGIN) parameters:@{@"ve_code":ve_code,@"pwd":pwdText.text,@"IP":IP} success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"~~~~~~~%@",responseObject);
                NSLog(@"%@",responseObject[@"msg"]);
                [USER_D setObject:responseObject[@"data"][@"ve_code"] forKey:@"ve_code"];//ve号
                //跳转页面
                if ([responseObject[@"code"] isEqualToString:@"012"]) {
                    NSLog(@"%d",[responseObject[@"code"]intValue]);
                    [HTTPURL authorizationsuccess:^(NSURLSessionDataTask *task, id responseObject) {
                        NSLog(@"%@",responseObject);
                        [USER_D setObject:responseObject[@"value"] forKey:@"token"];
                        [USER_D synchronize];
                        HomePageViewController *vc = [HomePageViewController new];
                        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                        UIWindow *window =[[UIApplication  sharedApplication].delegate window];
                        window.rootViewController = nvc;
                    } Success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                    }];
                }else{
                    
                    UIAlertController * alert = [UICommonView showOneAlertWithTitle:@"提示" message:responseObject[@"msg"] preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确定" sureBlock:^{
                    }];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } filure:^(NSURLSessionDataTask *task, id error) {
                [regist promptViewmessage:@"网络失败" sureBlock:^{
                }];
            } showHUD:NO sucessMsg:@"" failureMsg:@""];

            HomePageViewController *vc = [HomePageViewController new];
            UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            UIWindow *window =[[UIApplication  sharedApplication].delegate window];
            window.rootViewController = nvc;
        }else{
            NSLog(@"");
        }
    } filure:^(NSURLSessionDataTask *task, id error) {

    }showHUD:YES sucessMsg:@"注册成功" failureMsg:@"注册失败"];
    [USER_D setObject:recText.text forKey:@"referees"];//推荐人
    [USER_D setObject:phoneText.text forKey:@"phone"];//手机号
    [USER_D setObject:pwdText.text forKey:@"password"];//密码
    [USER_D setObject:nickNameText.text forKey:@"nickName"];//昵称
}
//同意条款按钮
-(void)rightButton:(UIButton *)button
{
    if (lastButton==0) {
        [button setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];
    }else{
    [button setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
    }
    lastButton = !lastButton;
    NSLog(@"对勾按钮");
}
#pragma mark--键盘代理方法
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //使用NSNotificationCenter 键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    //使用NSNotificationCenter 键盘隐藏时
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark == 处理键盘覆盖问题  textfiled代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _editingTextField=textField;
    if (textField ==[self.view viewWithTag:[[_tagArray objectAtIndex:1]intValue]])
    {
        [textField setEnabled:NO];
    }
    NSLog(@"%ld", (long)textField.tag);
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"");
    if (textField == [self.view viewWithTag:[[_tagArray objectAtIndex:0]intValue]]) {
        //匹配推荐人姓名
        RegisteredVC *registered = self;
       [ HTTPURL postRequest:LINK_BASE_URL(TJVE) parameters:@{@"ve_code":textField.text} success:^(NSURLSessionDataTask *task, id responseObject) {
            UITextView *TJRtext = [self.view viewWithTag:[[_tagArray objectAtIndex:1]intValue]];
            if ([responseObject[@"code"] isEqualToString:@"001"]) {
                TJRtext.text = responseObject[@"data"];
            }else
            {
                [registered promptViewmessage:responseObject[@"msg"] sureBlock:^{
                    TJRtext.text = @"";
                    textField.text = @"";
                }];
                
            }
        } filure:^(NSURLSessionDataTask *task, id error) {
            [registered promptViewmessage:@"获取推荐人失败" sureBlock:^{
                
            }];
        }showHUD:NO sucessMsg:@"" failureMsg:@""];
    }
    //判断确认密码是否于密码相同
    if (textField == [self.view viewWithTag:[[_tagArray objectAtIndex:5]intValue]]) {
        UITextField *newPWD =[self.view viewWithTag:[[_tagArray objectAtIndex:4]intValue]];
        if ([textField.text isEqualToString:newPWD.text]) {
            //提示框
            NSLog(@"%@====%@",textField.text,newPWD.text);
            
        }else{
            [self promptViewmessage:@"确认密码不相同,请重新输入" sureBlock:^{
                textField.text = @"";
            }];
        }
    }
    [UIView animateWithDuration:durationTime animations:^{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    }];
}

//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    durationTime = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]; //得到键盘动画时间
    NSLog(@"time : %f",durationTime);
    NSLog(@"++height:%f",kbSize.height);
    keyboardHeight = kbSize.height;
    
    if (SCREEN_height - keyboardHeight-64 <= _editingTextField.tag) {
        CGFloat y = _editingTextField.tag - (SCREEN_height - keyboardHeight-120);
        [UIView animateWithDuration:durationTime animations:^{
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, -y, scrollView.frame.size.width, scrollView.frame.size.height);
        }];
        
    }
    
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"--height:%f",kbSize.height);
    keyboardHeight = kbSize.height;
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
//提示框
-(void)promptViewmessage:(NSString *)message sureBlock:(void(^)())sureBlock
{
    UIAlertController * alert= [UICommonView showOneAlertWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确实" sureBlock:^{
        sureBlock();
    }];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark == 收起键盘
-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    NSLog(@"点击了");
    [self.view endEditing:YES];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
