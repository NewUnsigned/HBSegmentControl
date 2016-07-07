//
//  HBZoomNavigationBar.m
//  HBSegmentControl
//
//  Created by 赵鹏 on 16/7/3.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "HBZoomNavigationBar.h"
#import "HBSegmentControl.h"
#import "UIView+Extension.h"

static NSString * const HBRefreshKeyPathContentOffset = @"contentOffset";
static NSString * const HBRefreshKeyPathContentInset  = @"contentInset";
static NSString * const HBRefreshKeyPathPanState      = @"state";
static NSString * const HBRefreshKeyPathContentSize   = @"contentSize";

@interface HBZoomNavigationBar ()

@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (strong, nonatomic) HBSegmentControl       *segment;
@property (strong, nonatomic) UIImageView            *logImageView;
@property (strong, nonatomic) UIButton               *leftItem;
@property (strong, nonatomic) UIButton               *rightItem;
@property (strong, nonatomic) UIView                 *seperateLine;
@property (assign, nonatomic) BOOL touchBegin;

@end

@implementation HBZoomNavigationBar

#pragma mark - initilize

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.logImageView];
        [self addSubview:self.segment];
        [self addSubview:self.leftItem];
        [self addSubview:self.rightItem];
        [self addSubview:self.seperateLine];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+ (instancetype)navigationBarWithFrame:(CGRect)frame delegate:(nullable id<HBZoomNavigationBarDelegate>)delegate {
    HBZoomNavigationBar *bar = [[HBZoomNavigationBar alloc]initWithFrame:frame];
    bar.zoomBarDelegate = delegate;
    return bar;
}

#pragma mark - private methods

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    if (scrollView) {
        [self addObservers];
    }
    for (NSInteger index = 0; index < scrollView.subviews.count; index++) {
        UIView *view = [scrollView.subviews objectAtIndex:index];
        if ([view isKindOfClass:[UIScrollView class]]){
            view.tag = 9898 + index;
            [self addObserversWithView:view];
        };
    }
}

- (void)addObserversWithView:(UIView *)view {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [view addObserver:self forKeyPath:HBRefreshKeyPathContentOffset options:options context:nil];
    [view addObserver:self forKeyPath:HBRefreshKeyPathContentInset options:options context:nil];
}

- (void)removeObserversWithView:(UIView *)view {
    [view removeObserver:self forKeyPath:HBRefreshKeyPathContentOffset];
    [view removeObserver:self forKeyPath:HBRefreshKeyPathContentInset];
}

- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:HBRefreshKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:HBRefreshKeyPathContentInset  options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:HBRefreshKeyPathPanState options:options context:nil];
}

- (void)removeObservers {
    [self.scrollView removeObserver:self forKeyPath:HBRefreshKeyPathContentOffset];
    [self.scrollView removeObserver:self forKeyPath:HBRefreshKeyPathContentInset];;
    [self.pan removeObserver:self forKeyPath:HBRefreshKeyPathPanState];
    self.pan = nil;
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]){
            // 添加监听
            [self removeObserversWithView:view];
        };
    }
}

#pragma mark - kvo actions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    if ([keyPath isEqualToString:HBRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change object:object];
    }
    
    if ([keyPath isEqualToString:HBRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change object:(id)object];
    } else if ([keyPath isEqualToString:HBRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change object:(id)object];
    }
}

//static CGFloat const HBSegmentStatusBarHeight   = 64.0f;
//
//static CGFloat const HBSegmentMaxTop   = 64.0f;
//static CGFloat const HBSegmentMinTop   = 64.0f;
//static CGFloat const HBSegmentHeight   = 20.0f;
//
//static CGFloat const HBLogImageViewMaxTop  = 34.0f;
//static CGFloat const HBogImageViewMinTop   = 2.0f;
//static CGFloat const HBogImageViewHeight   = 16.0f;
//
//static CGFloat const HBSeperateLineMaxTop   = 83.0f;
//static CGFloat const HBSeperateLineMinTop   = 63.0f;
//static CGFloat const HBSeperateLineHeight   = 63.0f;
//

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change object:(id)object{
    CGPoint old = [change[@"old"] CGPointValue];
    CGPoint new = [change[@"new"] CGPointValue];
    if ([object isEqual:_scrollView]) {
        [_segment updateIndicatorPositionWithOffset:(new.x) direction:(new.x > old.x)];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            
            if (new.y < 0) {
                self.segment.vTop = 63;
                self.logImageView.vTop = 34;
                self.logImageView.alpha = 1;
                self.seperateLine.vTop = self.vHeight - 1;
                if (_scrollView) {
                    self.vHeight = 84;
                    _scrollView.vTop = self.vHeight;
                }
            } else if(new.y > 64){
                self.segment.vTop = 32;
                self.logImageView.vTop = 2;
                self.logImageView.alpha = 0;
                self.seperateLine.vTop = 63;
                if (_scrollView) {
                    self.vHeight = 64;
                    _scrollView.vTop = self.vHeight;
                }
            } else {
                CGFloat distance = new.y - old.y;
                if (self.segment.vTop <= 32 && new.y > old.y) {
                    return;  //
                }
                if (self.segment.vTop >= 32) {
                    self.segment.vTop -= distance * 0.5;
                }
                if (self.logImageView.vTop >= 2) {
                    self.logImageView.vTop -= distance * 0.5 ;
                }
                if (self.logImageView.alpha >= 0) {
                    self.logImageView.alpha -= (distance * 0.5 / 32);
                    
                }
                if (self.seperateLine.vTop >= 63) {
                    self.seperateLine.vTop -= (distance * 0.5 / 32) * 20;
                }
                
                if (_scrollView && [_scrollView isKindOfClass:[UIScrollView class]]) {
                    if (self.vHeight >= 64) {
                        self.vHeight -= (distance * 0.5 / 32) * 20;
                    }
                    if (_scrollView.vTop >= 64) {
                        _scrollView.vTop -= (distance * 0.5 / 32) * 20;
                    }
                }
            }
        }];
    }
}

//- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change object:(id)object{
//    CGPoint old = [change[@"old"] CGPointValue];
//    CGPoint new = [change[@"new"] CGPointValue];
//    if ([object isEqual:_scrollView]) {
//        [_segment updateIndicatorPositionWithOffset:(new.x - old.x)];
//    } else {
//        [UIView animateWithDuration:0.15 animations:^{
//            
//            if (new.y <= 0) {
//                self.segment.vTop = self.vHeight - HBSegmentHeight - HBSeperateLineHeight;
//                self.logImageView.vTop = HBStatusBarHeight + (HBBarBottomViewHeight - HBLogImageViewHeight) * 0.5;
//                self.logImageView.alpha = 1;
//                self.seperateLine.vTop = self.vHeight - HBSeperateLineHeight;
//                if (_scrollView) {
//                    self.vHeight = _orginalHeight;
//                    _scrollView.vTop = self.vHeight;
//                }
//            } else if(new.y > _orginalHeight - HBSegmentHeight){
//                self.segment.vTop = HBStatusBarHeight + (HBBarBottomViewHeight - HBSegmentHeight) * 0.5;
//                self.logImageView.vTop = HBStatusBarHeight + (HBBarBottomViewHeight - HBLogImageViewHeight) * 0.5 - HBSegmentHeight;
//                self.logImageView.alpha = 0;
//                self.seperateLine.vTop = _orginalHeight - HBSeperateLineHeight - HBSegmentHeight;
//                if (_scrollView) {
//                    self.vHeight = _orginalHeight - HBSegmentHeight;
//                    _scrollView.vTop = self.vHeight;
//                }
//            } else {
//                CGFloat distance = new.y - old.y;
//                if (self.segment.vTop >= 32) {
//                    self.segment.vTop -= distance * 0.5;
//                }
//                if (self.logImageView.vTop >= 2) {
//                    self.logImageView.vTop -= distance * 0.5 ;
//                }
//                if (self.logImageView.alpha >= 0) {
//                    self.logImageView.alpha -= (distance * 0.5 / 32);
//                    
//                }
//                if (self.seperateLine.vTop >= 63) {
//                    self.seperateLine.vTop -= (distance * 0.5 / 32) * 20;
//                }
//                
//                if (_scrollView && [_scrollView isKindOfClass:[UIScrollView class]]) {
//                    if (self.vHeight >= 64) {
//                        self.vHeight -= (distance * 0.5 / 32) * 20;
//                    }
//                    if (_scrollView.vTop >= 64) {
//                        _scrollView.vTop -= (distance * 0.5 / 32) * 20;
//                    }
//                }
//            }
//        }];
//    }
//}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change object:(id)object{
    
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change object:(id)object{

}

#pragma mark - setter && getter && dealloc

- (UIButton *)rightItem{
    if (!_rightItem) {
        _rightItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
        [_rightItem setImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
        _rightItem.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _rightItem;
}

- (UIButton *)leftItem{
    if (!_leftItem) {
        _leftItem = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 44, 20, 44, 44)];
        [_leftItem setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        _leftItem.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _leftItem;
}

- (UIView *)seperateLine{
    if (!_seperateLine) {
         _seperateLine = [[UIView alloc]initWithFrame:CGRectMake(0, 84 - 1, CGRectGetWidth([UIScreen mainScreen].bounds), 1)];
         _seperateLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
    return _seperateLine;
}

- (UIImageView *)logImageView{
    if (!_logImageView) {
        _logImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 34, CGRectGetWidth(self.frame) - 100, 16)];
        _logImageView.image = [UIImage imageNamed:@"hotbody"];
        _logImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logImageView;
}

- (HBSegmentControl *)segment{
    if (!_segment) {
        CGRect frame = CGRectMake(44, 63, CGRectGetWidth(self.frame) - 44 * 2, 20);
        __weak typeof(self)weakSelf = self;
        _segment = [HBSegmentControl segmentWithFrame:frame titles:@[@"关注",@"推推荐",@"精选",@"最推新"] selectedBlock:^(HBSegmentControl *segment, NSInteger index) {
            if (weakSelf.zoomBarDelegate && [weakSelf.zoomBarDelegate respondsToSelector:@selector(navigationBar:didSelecedtedSegmentIndex:)]) {
                [weakSelf.zoomBarDelegate navigationBar:weakSelf didSelecedtedSegmentIndex:index];
            }
        }];
        _segment.indicatorSizeMatchesTitle = YES;
    }
    return _segment;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self removeObservers];
}

@end
