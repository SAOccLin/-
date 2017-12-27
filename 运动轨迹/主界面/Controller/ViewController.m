//
//  ViewController.m
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "machineModel.h"
#import "MapViewController.h"
#import "FMDBTool.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)AFHTTPSessionManager *manage;
@property (nonatomic,strong)NSMutableArray *machineArrary;
@property (nonatomic,strong)UIButton *save;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"轨迹演示";
    
    [self setRightButton];
    [self.machineArrary addObjectsFromArray:[[FMDBTool shareDataBase] selectM_Code]];
    
    [self setTableView];
}

-(void)setRightButton{
    //右侧的菜单按钮
//    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [menuBtn addTarget:self action:@selector(showDropDownMenu1) forControlEvents:UIControlEventTouchUpInside];
//    [menuBtn setImage:[UIImage imageNamed:@"加号 1.png"] forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    
    self.save = [UIButton buttonWithType:UIButtonTypeCustom];
    self.save.frame = CGRectMake(0.0, 0.0, 40, 40);
    [self.save setTitle:@"添加" forState:UIControlStateNormal];
    [self.save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.save.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.save addTarget:self action:@selector(showDropDownMenu1) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:self.save];
    [self.save setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = saveItem;
}

-(void)showDropDownMenu1{
    [self showDropDownMenu:NO];
}



//正则
- (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[0-9]*$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

-(void)setTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;//取消自动对齐
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceHorizontal = NO;
    self.tableView.alwaysBounceVertical = NO;
    //注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.machineArrary.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.machineArrary[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    MapViewController *vc = [[MapViewController alloc]init];
    vc.m_code = self.machineArrary[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

/** 确定哪些行的cell可以编辑 (UITableViewDataSource协议中方法). */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//指定cell的编辑状态(删除还是插入)(UITableViewDelegate 协议方法)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

/** 提交编辑状态 (UITableViewDataSource协议中方法). */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    /**   点击 删除 按钮的操作 */
    if (editingStyle == UITableViewCellEditingStyleDelete) { /**< 判断编辑状态是删除时. */
        [self prompt:indexPath];
    }
}

-(void)showDropDownMenu:(BOOL)message{
    if (message == YES) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入机器唯一编号" message:@"请正确输入机器码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];//初始化一个alertView
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];//setAlertViewStyle
        [alertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入机器唯一编号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];//初始化一个alertView
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];//setAlertViewStyle
        [alertView show];
    }
}

//alertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *evaluate = [alertView textFieldAtIndex:0];//获取alertView的文本框
//        evaluate.keyboardType = UIKeyboardTypePhonePad;
        if (evaluate.text.length == 15&&[self validatePassword:evaluate.text]) {
            [self.machineArrary insertObject:evaluate.text atIndex:0];
            [self.tableView reloadData];
            [[FMDBTool shareDataBase] insertM_Code:evaluate.text];
        }else{
            [self showDropDownMenu:YES];
        }
        
        NSLog(@"输入框内容:%@",evaluate.text);
    }
}

//提示框
-(void)prompt:(NSIndexPath *)indexPath{
    // 1.创建alert控制器
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除机器" preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加按钮以及触发事件
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *m_code = [NSString stringWithFormat:@"%@",self.machineArrary[indexPath.row]];
        
        [[FMDBTool shareDataBase] deleteM_Code:m_code];
        /** 1. 更新数据源(数组): 根据indexPaht.row作为数组下标, 从数组中删除数据. */
        [self.machineArrary removeObjectAtIndex:indexPath.row];
        /** 2. TableView中 删除一个cell. */
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    
    // 3.presentViewController弹出一个控制器
    [self presentViewController:alertVc animated:YES completion:nil];
}

-(AFHTTPSessionManager *)manage{
    if (!_manage) {
        _manage = [AFHTTPSessionManager manager];
        _manage.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manage.responseSerializer = [AFHTTPResponseSerializer serializer];
        //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
        _manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [_manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    return _manage;
}

-(NSMutableArray *)machineArrary{
    if (!_machineArrary) {
        _machineArrary = [NSMutableArray array];
    }
    return _machineArrary;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
