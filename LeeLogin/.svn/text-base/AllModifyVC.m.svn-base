



//
//  AllModifyVC.m
//  LeeLogin
//
//  Created by 李雪虎 on 16/8/2.
//  Copyright © 2016年 Leexiaohu. All rights reserved.
//

#import "AllModifyVC.h"
#import "PersonalInformationVC.h"
@interface AllModifyVC ()<UITextFieldDelegate>
{
    UITextField *_textField;
    NSArray *_chooseArr;
    UIButton * lastButton;
}
@end

@implementation AllModifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleString;
    //导航完成按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_width-50, 24, 40, 40);
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = BGCOLOR;
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    
    
    if ([_titleString isEqualToString:@"邮箱"])
    {
    
        [button setTitle:@"发送验证" forState:UIControlStateNormal];
         button.frame = CGRectMake(SCREEN_width-90, 24, 80, 80);
        UILabel *label = [LeeAllView allLabelWith:CGRectMake(10, 160, SCREEN_width-30, 90) withTextColor:TEXTCOLOR];
        label.text = @"注:请输入您绑定的邮箱账号,发送验证邮件,进入邮箱内确认连接完成绑定。";
        label.numberOfLines = 0;
        [self.view addSubview:label];
         [self textfieldView];//输入框
    }else{
        if ([_titleString isEqualToString:@"企业员工"]||[_titleString isEqualToString:@"婚姻状况"]||[_titleString isEqualToString:@"有无子女"]||[_titleString isEqualToString:@"政治面貌"]||[_titleString isEqualToString:@"养老保险"]||[_titleString isEqualToString:@"人寿保险"])
        {
            if ([_titleString isEqualToString:@"企业员工"]){
                _chooseArr = @[@"是",@"否"];
            }else if ([_titleString isEqualToString:@"有无子女"]||[_titleString isEqualToString:@"养老保险"]||[_titleString isEqualToString:@"人寿保险"]){
                _chooseArr = @[@"有",@"无"];
            }else if ([_titleString isEqualToString:@"政治面貌"]){
                _chooseArr = @[@"团员",@"党员",@"积极分子",@"群众"];
            }else if ([_titleString isEqualToString:@"婚姻状况"]){
                 _chooseArr = @[@"已婚",@"未婚"];
            }
            
            [self chooseView];//选择按钮
            
        }else
        {
            [self textfieldView];//输入框
        }
        [button setTitle:@"完成" forState:UIControlStateNormal];
        button.frame = CGRectMake(SCREEN_width-50, 24, 40, 40);
      
    }
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}
//完成按钮
- (void)buttonClick
{
    [self.delegate refreshList];//回调刷新
    NSLog(@"%@",_textString);
    NSLog(@"%@",_titleString);
    [USER_D setObject:_textString forKey:_titleString];
    [USER_D synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
     _textString = [NSString stringWithFormat:@"%@",textField.text];
      NSLog(@"%@",_textString);
}
//输入视图
-(void)textfieldView
{
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(10,100,SCREEN_width-20,50 )];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.font = THIRTEEN;//字体大小
    _textField.delegate = self;
    [self.view addSubview:_textField];
}
//选择视图
-(void)chooseView
{
    for (int i=0; i<_chooseArr.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle:_chooseArr[i] forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 100+(i*60), SCREEN_width-20, 50);
        button.tag = i+10;
        //按钮编辑
        [button.layer setMasksToBounds:YES];
        //边框宽度
        [button.layer setBorderWidth:1.0];
        //边框圆角半径
        [button.layer setCornerRadius:10.0];
        //边框颜色
        button.layer.borderColor=[UIColor grayColor].CGColor;
        button.titleLabel.font = THIRTEEN;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(chooseButttonClicke:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}
#pragma mark -- 按钮点击事件
//是否按钮事件
-(void)chooseButttonClicke:(UIButton *)button
{
    lastButton.backgroundColor = [UIColor whiteColor];
    button.backgroundColor = COLOR(27, 124, 204, 1);
    _textString = button.titleLabel.text;
    NSLog(@"%@",_textString);
    lastButton =button;
    
}
//键盘下去
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
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
