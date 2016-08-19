//
//  MemberTeacherViewController.m
//  ShiMingRenZheng
//
//  Created by 吕涛 on 16/8/4.
//  Copyright © 2016年 吕涛. All rights reserved.
//

#import "MemberTeacherViewController.h"
#import "ASingleSparkViewController.h"
#import "WebViewController.h"
#import "LecturerLeverWebViewController.h"
#define LECTURER_LEVEL LINK_URL(@"/userTeach/findTeachLevel") //获取讲师级别

@interface MemberTeacherViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * memebrTableView;

@property (nonatomic,strong) NSArray * titleArr;

@end

@implementation MemberTeacherViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置返回按钮
    NvigationItemSingle * single = BACK_NAVIGATION;
    [single setNavigationBackItem:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.view.backgroundColor = BGCOLOR;
    self.title = @"会员讲师";
    self.titleArr = [[NSArray alloc]initWithObjects:@"讲师信息",@"讲师等级",@"星星之火", nil];
    [self.view addSubview:self.memebrTableView];
    [self getTeachLevel];
}

#pragma mark == 获取讲师等级
-(void)getTeachLevel{
//    HTTPURL * HTTP  = [HTTPURL new];
//    [HTTP postRequestwithUrlStr:LECTURER_LEVEL withUpDic:@{@"sccess_token":ACCESS_TOKEN} withBlock:^(NSDictionary *dic) {
//        //获取讲师等级
//        NSLog(@"讲师等级===%@",dic);
//    }];
    [HTTPURL postRequest:LECTURER_LEVEL parameters:@{@"sccess_token":ACCESS_TOKEN} success:^(NSURLSessionDataTask *task, id responseObject) {
       NSLog(@"讲师等级===%@",responseObject[@"msg"]);
        
    } filure:^(NSURLSessionDataTask *task, id error) {
        
    }showHUD:NO sucessMsg:@"" failureMsg:@""];
}

#pragma mark = = 初始化tableView
-(UITableView *)memebrTableView{
    if (!_memebrTableView) {
        _memebrTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_width, self.titleArr.count*50+60) style:UITableViewStylePlain];
        _memebrTableView.delegate = self;
        _memebrTableView.dataSource = self;
        _memebrTableView.showsVerticalScrollIndicator = NO;
        _memebrTableView.bounces = NO;
        _memebrTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _memebrTableView;
}

#pragma mark = = delegate & datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
//区头
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel * lvLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_width, 60)];
    lvLabel.font = [UIFont boldSystemFontOfSize:15];
    lvLabel.textAlignment = NSTextAlignmentCenter;
    lvLabel.backgroundColor = BGCOLOR;
    NSString * text = [NSString stringWithFormat:@"%@ [%@]",@"ve号",@"等级"];
    
    //添加副文本
    NSRange range = [text rangeOfString:@" "];
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:text];
    [attStr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(range.location+1,[text length]-range.location-1 )];
    
    lvLabel.attributedText = attStr;
    
    return lvLabel;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellid = @"MemberTeacher";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        LecturerLeverWebViewController * vc = [[LecturerLeverWebViewController alloc]init];
        vc.titleString = @"讲师信息";
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if(indexPath.row == 1){
        
        WebViewController * vc = [[WebViewController alloc]init];
        vc.urlString = LINK_URL(@"/lecturer/lecturerLever");
        vc.titleString = @"讲师等级";
        [self.navigationController pushViewController:vc animated:YES];

    }else if (indexPath.row == 2){
        ASingleSparkViewController * vc = [ASingleSparkViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
