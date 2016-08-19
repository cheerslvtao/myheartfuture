//
//  FillInformationViewController.m
//  ShiMingRenZheng
//
//  Created by 吕涛 on 16/8/1.
//  Copyright © 2016年 吕涛. All rights reserved.
//

#import "FillInformationViewController.h"
#import "CDCardCell.h"
#import "UICommonView.h"
#import "SubmitPhotoCell.h"
#define AUTHENTICATION_SUBMIT LINK_URL(@"/userAccount/saveUserAuth") //用户发起实名认证提交

@interface FillInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITextField * _nameField;
    UITextField * _IDcardField;
    NSData * _frontPicData;//身份证正面照片
    NSData * _backPicData; //身份证背面照片
    NSInteger _selecCellIndex;
    int flag[2];

}

@property (nonatomic,strong) UITableView * fillInfoTable;

@end

@implementation FillInformationViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"提交认证";
    self.view.backgroundColor = BGCOLOR;
    
    //设置返回按钮  不放在ViewWillappear里面 这是最后一个页面了
    NvigationItemSingle * single = BACK_NAVIGATION;
    [single setNavigationBackItem:self];


    [self.view addSubview:self.fillInfoTable];
    [self createSubmitButton];
}


#pragma mark == 提交审核按钮 & 点击事件
-(void)createSubmitButton{
    UIButton * btn = [LeeAllView BigButton:CGRectMake(10, SCREEN_height-64, SCREEN_width-20, 40) withTitel:@"提交审核"];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(submitInfo) forControlEvents:UIControlEventTouchUpInside];
}

-(void)submitInfo{
    //认证
    
    if(!_frontPicData || !_backPicData){
        UIAlertController * alert = [UICommonView showOneAlertWithTitle:@"温馨提示" message:@"照片为空" preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确定"  sureBlock:^{
            NSLog(@"确定");
        }];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSDictionary * parameters = @{@"veCode":VE_CODE,
                                  @"sccess_token":ACCESS_TOKEN,
                                  @"idCard":_IDcardField.text,
                                  @"realName":_nameField.text,
                                  @"frontPic":_frontPicData,
                                  @"backPic":_backPicData};
    
    __weak typeof(self) weakSelf = self;
    
    [HTTPURL postRequest:AUTHENTICATION_SUBMIT parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNotification * notification = [NSNotification notificationWithName:@"statusChanged" object:nil userInfo:@{@"status":@"Authenticationing",@"sectionNum":@1}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [weakSelf.navigationController popViewControllerAnimated:YES];

    } filure:^(NSURLSessionDataTask *task, id error) {
        
    }showHUD:YES sucessMsg:@"上传成功" failureMsg:@"上传失败"];
    
}

#pragma mark == 初始化tableView
-(UITableView * )fillInfoTable{
    if (!_fillInfoTable) {
        _fillInfoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, SCREEN_height-64-84) style:UITableViewStylePlain];
        _fillInfoTable.delegate= self;
        _fillInfoTable.dataSource =self;
        _fillInfoTable.showsVerticalScrollIndicator = NO;
        _fillInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _fillInfoTable.estimatedRowHeight = 200;
        _fillInfoTable.rowHeight = UITableViewAutomaticDimension;
        
        _fillInfoTable.tableHeaderView = [self headerView]; //表头
        [_fillInfoTable registerNib:[UINib nibWithNibName:@"CDCardCell" bundle:nil] forCellReuseIdentifier:@"CDCardCell"];
        [_fillInfoTable registerNib:[UINib nibWithNibName:@"SubmitPhotoCell" bundle:nil] forCellReuseIdentifier:@"SubmitPhotoCell"];
    }
    return _fillInfoTable;
}

-(UIView *)headerView{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, 160)];
    view.backgroundColor = BGCOLOR;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(registeFirstResponder)];
    [view addGestureRecognizer:tap];

    _nameField = [self customTextFieldWithFrame:CGRectMake(10, 20, SCREEN_width-20, 40) title:@" 姓名"];
    _IDcardField = [self customTextFieldWithFrame:CGRectMake(10, 70, SCREEN_width-20, 40) title:@" 身份证号"];
    _IDcardField.keyboardType = UIKeyboardTypeNamePhonePad;
    
    _IDcardField.delegate =self;
    _nameField.delegate = self;
    
    UILabel * alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, SCREEN_width-20, 40)];
    alertLabel.textColor = [UIColor grayColor];
    alertLabel.text = @" 身份证照支持jpg/png格式";
    
    [view addSubview:alertLabel];
    [view addSubview:_nameField];
    [view addSubview:_IDcardField];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (flag[indexPath.row] == 1) {
        CDCardCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CDCardCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.photoImg.image = [UIImage imageWithData:_frontPicData];
        }else{
            cell.titleLabel.text = @"身份证背面照片";
            cell.photoImg.image = [UIImage imageWithData:_backPicData];
        }
        cell.tag = 89892+indexPath.row;
        cell.UploadPhoto.tag = cell.tag+100;
        [cell.UploadPhoto addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    SubmitPhotoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SubmitPhotoCell" forIndexPath:indexPath];
    
    cell.tag = 8989+indexPath.row;
    cell.UploadButton.tag = cell.tag+100;
    
    [cell.UploadButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
#pragma mark == 点击图片选择头像
-(void)selectPhoto:(UIButton *)btn{
    
    _selecCellIndex = btn.tag - 100;
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self pikePhoto:UIImagePickerControllerSourceTypeCamera];
        }else{
            NSLog(@"没有找到相关设备");
        }
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self pikePhoto:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)pikePhoto:(UIImagePickerControllerSourceType)sourceType {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark ==代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (_selecCellIndex == 8989 || _selecCellIndex == 89892) {
        flag[0] = 1;
        _frontPicData = UIImagePNGRepresentation(image);
    }else{
        flag[1] = 1;
        _backPicData = UIImagePNGRepresentation(image);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.fillInfoTable reloadData];
}



#pragma mark == 自定义textFiled
-(UITextField * )customTextFieldWithFrame:(CGRect)rect title:(NSString *)title{
    
    UITextField * field = [[UITextField  alloc]initWithFrame:rect];
    field.layer.borderWidth = 0.4;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.layer.cornerRadius = 5;
    field.adjustsFontSizeToFitWidth = YES;
    field.layer.borderColor = [UIColor grayColor].CGColor;
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, 80, rect.size.height)];
    label.text = title;
    label.textColor = [UIColor grayColor];
    label.layer.borderWidth = 0.2;
    label.backgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:252/255.0 alpha:1];
    label.adjustsFontSizeToFitWidth = YES;
    
    field.leftView = label;
    field.leftViewMode = UITextFieldViewModeAlways;
    return field;
}

#pragma mark ==textfield delegate && 收起键盘操作

-(void)registeFirstResponder{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_IDcardField == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 18) { //如果输入框内容大于20则弹出警告
            
            textField.text = [toBeString substringToIndex:18];
            [textField resignFirstResponder];
            return NO;
        }
    }
    return YES;
}




@end
