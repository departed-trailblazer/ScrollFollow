//
//  ViewController.m
//  ScrollFollow
//
//  Created by 马聪 on 16/3/17.
//  Copyright © 2016年 马聪. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#define NavgationBar_Height 64
#define TabBar_Height 49
#define StatusBar_Height 20
#define NavgationBar_Hidden_Y 30
#define Bar_Hidden_Y 25

static CGFloat statueBarFrameY = 0;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tabelView;

@property (nonatomic, strong) NSMutableArray *tabelViewArray;

@property (nonatomic, assign) CGPoint lastOffset; //最后的偏移量

@property (nonatomic, assign) BOOL needHiddenBar;    //是否需要隐藏各工具栏

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
    self.tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tabelView.delegate = self;
    self.tabelView.dataSource = self;
    [self.view addSubview:self.tabelView];
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        
    {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        UIEdgeInsets insets = self.tabelView.contentInset;
        
        insets.top =self.navigationController.navigationBar.bounds.size.height + StatusBar_Height;
        
        self.tabelView.contentInset =insets;
        self.tabelView.scrollIndicatorInsets = insets;
        
        
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.lastOffset.y - scrollView.contentOffset.y;  //获取偏移量y值
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = appDelegate.tabBarController;
    
    //已经滑动到最上端
    if (scrollView.contentOffset.y < 0) {
        offsetY = 0;
        self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, NavgationBar_Height);
        
        tabBarController.tabBar.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - TabBar_Height, [UIScreen mainScreen].bounds.size.width, TabBar_Height);
        
        NSValue *statueBarFrameValue = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, StatusBar_Height)];
        
        [[UIApplication sharedApplication] setValue:statueBarFrameValue forKeyPath:@"statusBar.frame"];
        statueBarFrameY = 0;
        return;
    }
    
    //已经滑动到最下端
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height) {
        offsetY = 0;
    }
    
    //状态栏位置
    statueBarFrameY += offsetY * 0.5;
    
    if (statueBarFrameY < -NavgationBar_Hidden_Y) {
        statueBarFrameY = -NavgationBar_Hidden_Y;
    }
    
    if (statueBarFrameY > 0) {
        statueBarFrameY = 0;
    }
    
    NSValue *statueBarFrameValue = [NSValue valueWithCGRect:CGRectMake(0, statueBarFrameY, [UIScreen mainScreen].bounds.size.width, StatusBar_Height)];
    
    //通过kvc改变状态栏位置
    [[UIApplication sharedApplication] setValue:statueBarFrameValue forKeyPath:@"statusBar.frame"];
    
    //导航栏位置
    CGFloat navgationBarFrameY = self.navigationController.navigationBar.frame.origin.y + offsetY;
    
    if (navgationBarFrameY < -NavgationBar_Height) {
        navgationBarFrameY = -NavgationBar_Height;
    }
    
    if (navgationBarFrameY > 0) {
        navgationBarFrameY = 0;
    }
    //改变navgationBar位置
    self.navigationController.navigationBar.frame = CGRectMake(0, navgationBarFrameY, [UIScreen mainScreen].bounds.size.width, NavgationBar_Height);
    
    //tabBar位置
    CGFloat tabBarFrameY = tabBarController.tabBar.frame.origin.y - offsetY;
    
    if (tabBarFrameY < [UIScreen mainScreen].bounds.size.height - TabBar_Height) {
        tabBarFrameY = [UIScreen mainScreen].bounds.size.height - TabBar_Height;
    }
    
    if (tabBarFrameY > [UIScreen mainScreen].bounds.size.height) {
        tabBarFrameY = [UIScreen mainScreen].bounds.size.height;
    }
    
    //改变tabBar位置
    tabBarController.tabBar.frame = CGRectMake(0,tabBarFrameY, [UIScreen mainScreen].bounds.size.width, TabBar_Height);
    self.lastOffset = scrollView.contentOffset;
    
    //需不需要隐藏
    self.needHiddenBar = navgationBarFrameY < -NavgationBar_Hidden_Y;
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView.contentOffset.y < Bar_Hidden_Y) {
        self.needHiddenBar = NO;
    }
    
    CGFloat navigationBarFrameY = 0;
    CGFloat tabBarFrameY = 0;
    
    //判断是否需要隐藏
    if (self.needHiddenBar) {
        navigationBarFrameY = -NavgationBar_Height;
        tabBarFrameY = [UIScreen mainScreen].bounds.size.height;
        statueBarFrameY = -NavgationBar_Hidden_Y;
    } else {
        navigationBarFrameY = 0;
        tabBarFrameY = [UIScreen mainScreen].bounds.size.height - TabBar_Height;
        statueBarFrameY = 0;
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = appDelegate.tabBarController;
    
    //执行动画
    [UIView animateWithDuration:0.2 animations:^{
        //导航栏
        self.navigationController.navigationBar.frame = CGRectMake(0, navigationBarFrameY, [UIScreen mainScreen].bounds.size.width, NavgationBar_Height);
        
        //tabBar
        tabBarController.tabBar.frame = CGRectMake(0,tabBarFrameY, [UIScreen mainScreen].bounds.size.width, TabBar_Height);
        
        //状态栏
        NSValue *statueBarFrameValue = [NSValue valueWithCGRect:CGRectMake(0, statueBarFrameY, [UIScreen mainScreen].bounds.size.width, StatusBar_Height)];
        
        [[UIApplication sharedApplication] setValue:statueBarFrameValue forKeyPath:@"statusBar.frame"];
        
    }];
}


#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 104;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identfier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    return cell;
}

@end
