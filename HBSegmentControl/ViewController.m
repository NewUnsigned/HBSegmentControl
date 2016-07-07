//
//  ViewController.m
//  HBSegmentControl
//
//  Created by 赵鹏 on 16/7/3.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ViewController.h"
#import "TestTableViewController.h"
#import "TestCollectionViewController.h"
#import "HBZoomNavigationBar.h"

@interface ViewController () <UIScrollViewDelegate,HBZoomNavigationBarDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) HBZoomNavigationBar *navBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    TestTableViewController *table = [[TestTableViewController alloc]init];
    table.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
    [self.scrollView addSubview:table.view];
    
    TestCollectionViewController *collect = [[TestCollectionViewController alloc]init];
    collect.collectionView.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
    [self.scrollView addSubview:collect.collectionView];
    
    TestTableViewController *table1 = [[TestTableViewController alloc]init];
    table1.view.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 2, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
    [self.scrollView addSubview:table1.view];
    
    TestCollectionViewController *collect1 = [[TestCollectionViewController alloc]init];
    collect1.collectionView.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 3, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)- 64);
    [self.scrollView addSubview:collect1.collectionView];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 4, 0);
    [self addChildViewController:table];
    [self addChildViewController:collect];
    [self addChildViewController:table1];
    [self addChildViewController:collect1];
    
    _navBar = [HBZoomNavigationBar navigationBarWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 84) delegate:self];
    [self.view addSubview:_navBar];
    _navBar.scrollView = self.scrollView;
}

- (void)navigationBar:(HBZoomNavigationBar *)navigationBar didSelecedtedSegmentIndex:(NSInteger)index {
    NSLog(@"选择了第%ld个标签",index);
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) * index, 0) animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

// 测试KVO监听有没有释放
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (self.navBar) {
//        [self.navBar removeFromSuperview];
//        self.navBar = nil;
//    } else {
//        _navBar = [HBZoomNavigationBar navigationBarWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 84) delegate:self];
//        [self.view addSubview:_navBar];
//        _navBar.scrollView = self.scrollView;
//    }
//}

#pragma mark - lazy

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 84, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64)];
        _scrollView.clipsToBounds = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
