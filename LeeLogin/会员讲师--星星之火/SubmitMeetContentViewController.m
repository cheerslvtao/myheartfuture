//
//  SubmitMeetContentViewController.m
//  ShiMingRenZheng
//
//  Created by 吕涛 on 16/8/4.
//  Copyright © 2016年 吕涛. All rights reserved.
//

#import "SubmitMeetContentViewController.h"
#import "MeetSubmitCell.h"
#import "CDCardCell.h"
#import "SubmitPhotoCell.h"
#import "LTAreaPicker.h"
#import "LTDatePicker.h"
#import <objc/runtime.h>
#import "AFNetworking.h"
#define MEET_SUBMIT LINK_BASE_URL(@"/userMeeting/addMeeting") //星星之火 ———— 会议提交

@interface SubmitMeetContentViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSData * _topPicData;//会前照片
    NSData * _midPicData; //会中照片
    NSData * _bottomPicData; //会后照片
    NSArray * imageArr; //图片数组
    NSInteger _selecCellIndex;
    int flag[3];
    UITextView * summaryTextView;//总结会议
    float currentOffset ;//当前tableView偏移量
}
@property (nonatomic,strong) UITableView * submitTableView;

@property (nonatomic,strong) NSArray * titleArr; //标题数组

@property (nonatomic,strong) NSArray * imgLogoArr; //右边小图标

@property (nonatomic,strong)NSMutableArray * textFiledArr; //存放textfield.text

@property (nonatomic,strong)NSArray * placeholdArr;//占位文字数组

@end

@implementation SubmitMeetContentViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置返回按钮
    NvigationItemSingle * single = BACK_NAVIGATION;
    [single setNavigationBackItem:self];
    
    //使用NSNotificationCenter 键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 键盘隐藏时
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BGCOLOR;
    self.title = @"会提提交";
    [self createRightCompeteButton];
    [self.view addSubview:self.submitTableView];

    
}

#pragma mark == 导航右边按钮
-(void)createRightCompeteButton{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 35);
    [btn setTitle:@"完 成" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark == 提交会议信息
-(void)submit{
    self.textFiledArr = [[NSMutableArray alloc]init]   ; //用于存放textfield的内容

    for (int i = 0; i<7; i++) {
        UITextField * field = [self.view viewWithTag:78592+i];
        if (field.text.length==0) {
            [self showAlert];
            return;
        }
        [self.textFiledArr addObject:field.text];
    }
    if (!_topPicData || !_midPicData|| !_bottomPicData || summaryTextView.text.length==0) {

        [self showAlert];
        return;
    }
    
    NSDictionary * dic = @{
                           @"access_token":ACCESS_TOKEN,
                           @"teachVeCode":self.textFiledArr[4],
                           @"title":self.textFiledArr[0],
                           @"sponsor":self.textFiledArr[3],
                           @"address":[NSString stringWithFormat:@"%@+%@",self.textFiledArr[1],self.textFiledArr[2]],
                           @"join_user":self.textFiledArr[6],
                           @"meeting_time":self.textFiledArr[5],
                           @"pic_start":[_topPicData base64EncodedDataWithOptions:0],
                           @"pic_center":[_midPicData base64EncodedDataWithOptions:0],
                           @"pic_end":[_bottomPicData base64EncodedDataWithOptions:0],
                           @"summary":summaryTextView.text
                               };
    /*
     @"pic_start":_topPicData,
     @"pic_center":_midPicData,
     @"pic_end":_bottomPicData,
     */
    
    NSLog(@"%@",MEET_SUBMIT);
    

    [HTTPURL postRequest:MEET_SUBMIT parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"提交会议列表%@",responseObject);
        [self.navigationController popViewControllerAnimated:YES];

    } filure:^(NSURLSessionDataTask *task, id error) {
        NSLog(@"提交列表异常-->%@",error);

    }showHUD:YES sucessMsg:@"提交成功" failureMsg:@"提交失败"];
    
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    NSArray * imageArray = [[NSArray alloc]initWithObjects:[UIImage imageWithData:_topPicData],[UIImage imageWithData:_midPicData],[UIImage imageWithData:_bottomPicData], nil];
//    NSArray * imageTitle = [[NSArray alloc]initWithObjects:@"pic_start",@"pic_center",@"pic_end", nil];
//    NSArray * imageDataArr = [[NSArray alloc]initWithObjects:_topPicData,_midPicData,_bottomPicData, nil];
//    
//        
////        NSData *data = UIImagePNGRepresentation(imageArray[i]);
////        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
////        formatter.dateFormat = @"yyyyMMddHHmmss";
////        NSString *str = [formatter stringFromDate:[NSDate date]];
////        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
//    
//    __weak typeof(self) weakSelf = self;
//    [manager POST:MEET_SUBMIT parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        for (int i = 0; i<imageArray.count; i++) {
//            UIImage * img = [UIImage imageWithData:imageDataArr[i]];
//            NSString * type = nil;
//            if ( UIImagePNGRepresentation(img) ) {
//                type = @"image/png";
//            }else{
//                type = @"image/jpeg";
//            }
//            [formData appendPartWithFileData:imageDataArr[i] name:imageTitle[i] fileName:imageTitle[i] mimeType:type];
//        }
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"progress --- %@",uploadProgress);
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Success: %@", responseObject);
////        NSString * str = [responseObject objectForKey:@"fileId"];
////        if (str != nil) {
////            [self UpImaheFinish:str];
////        }
//        [self.navigationController popViewControllerAnimated:YES];
//        [LeeAllView endHotWheels:self.view];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error == %@",error);
//        [LeeAllView endHotWheels:self.view];
//    }];
//        
//    

}

//-(void)UpImaheFinish:(NSString *)string
//{
//    if (string) {
//        [imageArr addObject:string];
//    }
//    if (imageArr.count == imageArray.count) {
//        
//        NSLog(@"%@",imageArr);
//        //返回的所有结果
//    }
//    
//}

-(void)showAlert{
    UIAlertController * alert = [UICommonView showOneAlertWithTitle:@"提示" message:@"请完善信息" preferredStyle:UIAlertControllerStyleAlert sureTitle:@"确定" sureBlock:^{
        
    }];

    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark == 初始化 tableView
-(UITableView *)submitTableView{
    if (!_submitTableView) {
        _submitTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, SCREEN_height-64) style:UITableViewStylePlain];
        _submitTableView.delegate =self;
        _submitTableView.dataSource = self;
        _submitTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _submitTableView.estimatedRowHeight = 50;
        _submitTableView.rowHeight = UITableViewAutomaticDimension;
        [_submitTableView registerNib:[UINib nibWithNibName:@"CDCardCell" bundle:nil] forCellReuseIdentifier:@"CDCardCell"];
        [_submitTableView registerNib:[UINib nibWithNibName:@"MeetSubmitCell" bundle:nil] forCellReuseIdentifier:@"MeetSubmitCell"];
        [_submitTableView registerNib:[UINib nibWithNibName:@"SubmitPhotoCell" bundle:nil] forCellReuseIdentifier:@"SubmitPhotoCell"];
        _submitTableView.tableFooterView = [self customFooter];
    }
    return _submitTableView;
}

#pragma mark == 表尾
-(UIView *)customFooter{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, 220)];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, SCREEN_width/3, 30)];
    label.text = [self.titleArr lastObject];
    label.font = [UIFont systemFontOfSize:15];
    [view addSubview:label];
    
    summaryTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 50, SCREEN_width-20, 170)];
    summaryTextView.text = @"您对本次会议的总结感想，限500字以内";
    summaryTextView.textColor = [UIColor grayColor];
    summaryTextView.delegate =self;
    [view addSubview:summaryTextView];
    
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count-1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<7) {
        MeetSubmitCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MeetSubmitCell" forIndexPath:indexPath];
        cell.textFiledCell.delegate = self;
        cell.titleLabel.text = self.titleArr[indexPath.row]; //标题
        UIImage * img = nil;
        if (indexPath.row == 1) {
            img = [UIImage imageNamed:@"icon_zss"];
        }else if(indexPath.row == 5){
            img = [UIImage imageNamed:@"icon_hysj"];
        }else if (indexPath.row == 6){
            img = [UIImage imageNamed:@"icon_adduser"];
        }
        cell.rightLogo.image = img;
        cell.textFiledCell.placeholder = self.placeholdArr[indexPath.row ];//textfiled 占位字符
        cell.textFiledCell.tag = 78592+indexPath.row;
        if (indexPath.row == 0||(indexPath.row >1 && indexPath.row<5) ) {
            cell.rightLogo.hidden = YES;
        }
        return cell;
    }

    if (flag[indexPath.row-7] == 1) {
        CDCardCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CDCardCell" forIndexPath:indexPath];
        if (indexPath.row == 7) {
            cell.titleLabel.text = @"会前照片";
            cell.photoImg.image = [UIImage imageWithData:_topPicData];

        }else if(indexPath.row == 8){
            cell.titleLabel.text = @"会中照片";
            cell.photoImg.image = [UIImage imageWithData:_midPicData];

        }else if (indexPath.row == 9){
            cell.titleLabel.text = @"会后照片";
            cell.photoImg.image = [UIImage imageWithData:_bottomPicData];
        }
        cell.tag = 78592+indexPath.row;
        cell.UploadPhoto.tag = cell.tag+100;
        [cell.UploadPhoto addTarget:self action:@selector(selectPhotoSubmit:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    SubmitPhotoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SubmitPhotoCell" forIndexPath:indexPath];
    
    cell.tag = 7859+indexPath.row;
    cell.UploadButton.tag = cell.tag+100;
    
    [cell.UploadButton addTarget:self action:@selector(selectPhotoSubmit:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;

}

#pragma mark == 点击图片选择头像
-(void)selectPhotoSubmit:(UIButton *)btn{
    
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

#pragma mark == 掉系统相册 代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (_selecCellIndex == 7859+7 || _selecCellIndex == 78592+7) {
        flag[0] = 1;

        _topPicData = UIImageJPEGRepresentation(image, 0.1);
    }else if(_selecCellIndex == 7859+8 || _selecCellIndex == 78592+8){
        flag[1] = 1;

        _midPicData = UIImageJPEGRepresentation(image, 0.1);
    }else{
        
        flag[2] = 1;
        
        _bottomPicData =UIImageJPEGRepresentation(image, 0.1);
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.submitTableView reloadData];
}



#pragma mark == 初始化数组
-(NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = [[NSArray alloc]initWithObjects:@"会议名称",@"会议地区",@"会议地点",@"主办人",@"讲师",@"会议时间",@"参会人员",@"会前照片",@"会中照片",@"会后照片",@"会议总结", nil];
    }
    return _titleArr;
}

-(NSArray *)placeholdArr{
    if (!_placeholdArr) {
        _placeholdArr = [[NSArray alloc]initWithObjects:@"会议的主题名称",@"选择省市区",@"",@"",@"",@"时间",@"张三、李四",@"会前照片",@"会中照片",@"会后照片",@"会议总结", nil];
    }
    return _placeholdArr;
}

#pragma mark  == textfileddelegate 键盘收起
//textfiled 防范
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"%@", textField.superview.superview);
    if ([textField.placeholder isEqualToString:@"选择省市区"]) {
        [self.view endEditing:YES];
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, SCREEN_height)];
        bgView.tag = 34654;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewDismiss)];
        [bgView addGestureRecognizer:tap];
        LTAreaPicker * pick = [[LTAreaPicker alloc]initWithFrame:CGRectMake(0, SCREEN_height-200, SCREEN_width, 200)];
        void (^myblock)(NSString *) = ^(NSString * areaStr){
            textField.text = areaStr;
            [bgView removeFromSuperview];
        };
        pick.returnBlock = myblock;
        [bgView addSubview:pick];
        [self.view addSubview:bgView];
        return NO;
    }
    if ([textField.placeholder isEqualToString:@"时间"]) {
        [self.view endEditing:YES];
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, SCREEN_height)];
        bgView.tag = 34654;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewDismiss)];
        [bgView addGestureRecognizer:tap];
        
        LTDatePicker * dateView = [[LTDatePicker alloc]initWithFrame:CGRectMake(0, SCREEN_height-200, SCREEN_width, 200)];
        void (^myblock)(NSString *) = ^(NSString * dateStr){
            textField.text = dateStr;
            [bgView removeFromSuperview];
        };
        [bgView addSubview:dateView];
        [self.view addSubview:bgView];
        dateView.returnBlock = myblock;
        
        return NO;
    }
    return YES;
}
-(void)bgViewDismiss{
    UIView * view = [self.view viewWithTag:34654];
    [view removeFromSuperview];
}

#pragma mark == textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView.text.length>100) {
        textView.textColor = [UIColor redColor];
    }else{
        textView.textColor = [UIColor grayColor];
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark == 处理键盘覆盖问题  textfiled代理方法
//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    currentOffset = self.submitTableView.contentOffset.y;
    
    float time = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:time animations:^{
        self.submitTableView.contentOffset =CGPointMake(0,  currentOffset+kbSize.height);
    }];
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.submitTableView.contentOffset =CGPointMake(0,  currentOffset);

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
