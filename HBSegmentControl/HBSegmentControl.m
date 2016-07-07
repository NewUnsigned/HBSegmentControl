//
//  HBSegmentControl.m
//  HBSegmentControl
//
//  Created by 赵鹏 on 16/7/3.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "HBSegmentControl.h"
#import "UIView+Extension.h"
#import "UIView+Frame.h"

// 导航条高度
static CGFloat const YZNavBarH = 64;

// 标题滚动视图的高度
static CGFloat const YZTitleScrollViewH = 44;

// 标题缩放比例
static CGFloat const YZTitleTransformScale = 1.3;

// 下划线默认高度
static CGFloat const YZUnderLineH = 2;

#define YZScreenW [UIScreen mainScreen].bounds.size.width
#define YZScreenH [UIScreen mainScreen].bounds.size.height

// 默认标题字体
#define YZTitleFont [UIFont systemFontOfSize:15]

// 默认标题间距
static CGFloat const margin = 20;

static NSString * const ID = @"cell";

@interface HBSegmentControl () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *segmentItems;
@property (strong, nonatomic) UIView         *indicatorView;
@property (strong, nonatomic) UIView         *bottomLine;
@property (assign, nonatomic) NSInteger       selectedIndex;
@property (assign, nonatomic) CGFloat         buttonWidth;


/** 所以标题宽度数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 下标视图 */
@property (nonatomic, weak) UIView *underLine;

/** 标题遮盖视图 */
@property (nonatomic, weak) UIView *coverView;

/** 记录上一次内容滚动视图偏移量 */
@property (nonatomic, assign) CGFloat lastOffsetX;

/** 记录是否点击 */
@property (nonatomic, assign) BOOL isClickTitle;

/** 记录是否在动画 */
@property (nonatomic, assign) BOOL isAniming;

/* 是否初始化 */
@property (nonatomic, assign) BOOL isInitial;

/** 标题间距 */
@property (nonatomic, assign) CGFloat titleMargin;

/** 计算上一次选中角标 */
@property (nonatomic, assign) NSInteger selIndex;

@end

@implementation HBSegmentControl

#pragma mark - initilize

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commentInitialize];
        self.delegate = self;
        _endR = 1;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

// 减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger offsetXInt = offsetX;
    NSInteger screenWInt = YZScreenW;
    
    NSInteger extre = offsetXInt % screenWInt;
    if (extre > YZScreenW * 0.5) {
        // 往右边移动
        offsetX = offsetX + (YZScreenW - extre);
        _isAniming = YES;
        [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }else if (extre < YZScreenW * 0.5 && extre > 0){
        _isAniming = YES;
        // 往左边移动
        offsetX =  offsetX - extre;
        [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    // 获取角标
    NSInteger i = offsetX / YZScreenW;
    
    // 选中标题
    [self setSelectedIndex:i animated:NO];
}


// 监听滚动动画是否完成
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isAniming = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    // 点击和动画的时候不需要设置
//    if (_isAniming || self.segmentItems.count == 0) return;
//    
//    // 获取偏移量
//    CGFloat offsetX = scrollView.contentOffset.x;
//    
//    // 获取左边角标
//    NSInteger leftIndex = offsetX / YZScreenW;
//    
//    // 左边按钮
//    UIButton *leftLabel = self.segmentItems[leftIndex];
//    
//    // 右边角标
//    NSInteger rightIndex = leftIndex + 1;
//    
//    // 右边按钮
//    UIButton *rightLabel = nil;
//    
//    if (rightIndex < self.segmentItems.count) {
//        rightLabel = self.segmentItems[rightIndex];
//    }
//    
//    // 字体放大
//    [self setUpTitleScaleWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
//    
//    // 设置下标偏移
//    if (_isDelayScroll == NO) { // 延迟滚动，不需要移动下标
//        
//        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
//    }
//    
//    // 设置遮盖偏移
//    [self setUpCoverOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
//    
//    // 设置标题渐变
//    [self setUpTitleColorGradientWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
//    
//    // 记录上一次的偏移量
//    _lastOffsetX = offsetX;
}


#pragma mark - 标题效果渐变方法
// 设置标题颜色渐变
- (void)setUpTitleColorGradientWithOffset:(CGFloat)offsetX rightLabel:(UIButton *)rightLabel leftLabel:(UIButton *)leftLabel
{
//    if (_isShowTitleGradient == NO) return;
    
    // 获取右边缩放
    CGFloat rightSacle = offsetX / YZScreenW - leftLabel.tag;
    
    // 获取左边缩放比例
    CGFloat leftScale = 1 - rightSacle;
    
    // RGB渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleRGB) {
        
        CGFloat r = _endR - _startR;
        CGFloat g = _endG - _startG;
        CGFloat b = _endB - _startB;
        
        // rightColor
        // 1 0 0
        UIColor *rightColor = [UIColor colorWithRed:_startR + r * rightSacle green:_startG + g * rightSacle blue:_startB + b * rightSacle alpha:1];
        
        // 0.3 0 0
        // 1 -> 0.3
        // leftColor
        UIColor *leftColor = [UIColor colorWithRed:_startR +  r * leftScale  green:_startG +  g * leftScale  blue:_startB +  b * leftScale alpha:1];
        
        // 右边颜色
        [rightLabel setTitleColor:rightColor forState:UIControlStateNormal];
        
        // 左边颜色
        [rightLabel setTitleColor:leftColor forState:UIControlStateNormal];

        return;
    }
    
    // 填充渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill) {
        
        // 获取移动距离
//        CGFloat offsetDelta = offsetX - _lastOffsetX;
//
//        if (offsetDelta > 0) { // 往右边
//            
//            
//            rightLabel.titleLabel.fillColor = self.selColor;
//            rightLabel.progress = rightSacle;
//            
//            leftLabel.fillColor = self.norColor;
//            leftLabel.progress = rightSacle;
//            
//        } else if(offsetDelta < 0){ // 往左边
//            
//            rightLabel.textColor = self.norColor;
//            rightLabel.fillColor = self.selColor;
//            rightLabel.progress = rightSacle;
//            
//            leftLabel.textColor = self.selColor;
//            leftLabel.fillColor = self.norColor;
//            leftLabel.progress = rightSacle;
        
//        }
    }
}

// 标题缩放
- (void)setUpTitleScaleWithOffset:(CGFloat)offsetX rightLabel:(UIButton *)rightLabel leftLabel:(UIButton *)leftLabel
{
//    if (_isShowTitleScale == NO) return;
    
    // 获取右边缩放
    CGFloat rightSacle = offsetX / YZScreenW - leftLabel.tag;
    
    CGFloat leftScale = 1 - rightSacle;
    
    CGFloat scaleTransform = _titleScale?_titleScale:YZTitleTransformScale;
    
    scaleTransform -= 1;
    
    // 缩放按钮
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * scaleTransform + 1, leftScale * scaleTransform + 1);
    
    // 1 ~ 1.3
    rightLabel.transform = CGAffineTransformMakeScale(rightSacle * scaleTransform + 1, rightSacle * scaleTransform + 1);
}

// 获取两个标题按钮宽度差值
- (CGFloat)widthDeltaWithRightLabel:(UIButton *)rightLabel leftLabel:(UIButton *)leftLabel
{
    CGRect titleBoundsR = [rightLabel.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    CGRect titleBoundsL = [leftLabel.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    return titleBoundsR.size.width - titleBoundsL.size.width;
}

// 设置下标偏移
- (void)setUpUnderLineOffset:(CGFloat)offsetX rightLabel:(UIButton *)rightLabel leftLabel:(UIButton *)leftLabel
{
//    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat underLineTransformX = offsetDelta * centerDelta / YZScreenW;
    
    // 宽度递增偏移量
    CGFloat underLineWidth = offsetDelta * widthDelta / YZScreenW;
    
    self.indicatorView.width += underLineWidth;
    self.indicatorView.x += underLineTransformX;
    
}

// 设置遮盖偏移
- (void)setUpCoverOffset:(CGFloat)offsetX rightLabel:(UIButton *)rightLabel leftLabel:(UIButton *)leftLabel
{
//    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat coverTransformX = offsetDelta * centerDelta / YZScreenW;
    
    // 宽度递增偏移量
    CGFloat coverWidth = offsetDelta * widthDelta / YZScreenW;
    
    self.coverView.width += coverWidth;
    self.coverView.x += coverTransformX;
    
}


// 标题按钮点击
//- (void)titleClick:(UITapGestureRecognizer *)tap
//{
//  
//}

- (void)selectLabel:(UIButton *)label
{
    
    for (UIButton *labelView in self.segmentItems) {
        
        if (label == labelView) continue;
        
//        if (_isShowTitleGradient && _titleColorGradientStyle == YZTitleColorGradientStyleRGB) {
        
            labelView.transform = CGAffineTransformIdentity;
//        }
        
//        labelView.textColor = self.norColor;
        
        if (_isShowTitleGradient && _titleColorGradientStyle == YZTitleColorGradientStyleFill) {
            
//            labelView.fillColor = self.norColor;
            
//            labelView.progress = 1;
        }
        
    }
    
    // 标题缩放
//    if (_isShowTitleScale && _titleColorGradientStyle == YZTitleColorGradientStyleRGB) {
    
        CGFloat scaleTransform = _titleScale?_titleScale:YZTitleTransformScale;
        
        label.transform = CGAffineTransformMakeScale(scaleTransform, scaleTransform);
//    }
    
    // 修改标题选中颜色
//    label.textColor = self.selColor;
    
    // 设置标题居中
    [self setLabelTitleCenter:label];
    
    // 设置下标的位置
    [self setUpUnderLine:label];
    
    // 设置cover
    [self setUpCoverView:label];
    
}

// 设置蒙版
- (void)setUpCoverView:(UIButton *)label
{
    // 获取文字尺寸
    CGRect titleBounds = [label.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    CGFloat border = 5;
    CGFloat coverH = titleBounds.size.height + 2 * border;
    CGFloat coverW = titleBounds.size.width + 2 * border;
    
    self.coverView.y = (label.height - coverH) * 0.5;
    self.coverView.height = coverH;
    
    
    // 最开始不需要动画
    if (self.coverView.x == 0) {
        self.coverView.width = coverW;
        
        self.coverView.x = label.x - border;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.width = coverW;
        
        self.coverView.x = label.x - border;
    }];
    
    
    
}

// 设置下标的位置
- (void)setUpUnderLine:(UIButton *)label
{
    // 获取文字尺寸
    CGRect titleBounds = [label.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    CGFloat underLineH = _underLineH?_underLineH:YZUnderLineH;
    
//    self.indicatorView.y = label.height - underLineH;
    self.indicatorView.height = underLineH;
    
    
    // 最开始不需要动画
    if (self.indicatorView.x == 0) {
        self.indicatorView.width = titleBounds.size.width;
        
        self.indicatorView.x = label.x;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorView.width = titleBounds.size.width;
        self.indicatorView.x = label.x;
    }];
    
}

// 让选中的按钮居中显示
- (void)setLabelTitleCenter:(UIButton *)label
{
    
//    // 设置标题滚动区域的偏移量
//    CGFloat offsetX = label.center.x - YZScreenW * 0.5;
//    
//    if (offsetX < 0) {
//        offsetX = 0;
//    }
//    
//    // 计算下最大的标题视图滚动区域
//    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - YZScreenW + _titleMargin;
//    
//    if (maxOffsetX < 0) {
//        maxOffsetX = 0;
//    }
//    
//    if (offsetX > maxOffsetX) {
//        offsetX = maxOffsetX;
//    }
//    
//    // 滚动区域
//    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        
        coverView.backgroundColor = _coverColor?_coverColor:[UIColor lightGrayColor];
        
        coverView.layer.cornerRadius = _coverCornerRadius;
        
        [self insertSubview:coverView atIndex:0];
        
        _coverView = coverView;
    }
    return _isShowTitleCover?_coverView:nil;
}

- (void)commentInitialize {
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bounces = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    _textColor = [UIColor lightGrayColor];
    _selectedTextColor = [UIColor blackColor];
    _normalFont      = [UIFont systemFontOfSize:12];
    _selectedFont    = [UIFont systemFontOfSize:12];
    
    _indicatorColor  = [UIColor blackColor];
    _indicatorHeight = 2;
    
    _indicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 2, 1, 2)];
    _indicatorView.backgroundColor = _indicatorColor;
    
    _animationDuration = 0.25;
}
//
+ (instancetype)segmentWithFrame:(CGRect)frame titles:(NSArray <NSString *> *)titles selectedBlock:(SelectedSegmentBlock)selectedBlock {
    HBSegmentControl *segment = [[HBSegmentControl alloc]initWithFrame:frame];
    segment.selectedBlock = selectedBlock;
    [segment addSegmentsWithTitles:titles];
    return segment;
}

#pragma mark - public method

- (void)addSegmentsWithTitles:(NSArray *)titles {
    _buttonWidth = _itemWidth && (_itemWidth * titles.count > CGRectGetWidth([UIScreen mainScreen].bounds)) ? _itemWidth : CGRectGetWidth(self.frame) / titles.count;
    CGSize size = [titles.firstObject sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    _indicatorView.vLeft = (_buttonWidth - size.width) * 0.5;
    _indicatorView.vWidth = size.width;

    [self redrawComponents];
    [self addButtonsWithTitles:titles ];
    [self redrawComponents];
}

- (void)updateTitle:(NSString *)title index:(NSInteger)index {
    if (index >= self.segmentItems.count) {
        return;
    } else {
        UIButton *item = [self.segmentItems objectAtIndex:index];
        [item setTitle:title forState:UIControlStateNormal];
    }
}

- (void)updateAllTitles:(NSArray <NSString *> *)titles {
    if (titles.count > self.segmentItems.count) {
        return;
    }
    
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.segmentItems.count) {
            UIButton *item = [self.segmentItems objectAtIndex:idx];
            [item setTitle:title forState:UIControlStateNormal];
        }
    }];
}

- (void)updateIndicatorPositionWithOffset:(CGFloat)offset direction:(BOOL)isRight{
//    UIButton *currentItem = [self.segmentItems objectAtIndex:_selectedIndex];
//    UIButton *nextItem;
//    if (isRight) {
//        nextItem = [_segmentItems objectAtIndex:(_selectedIndex + 1 >= _segmentItems.count ? _selectedIndex : _selectedIndex + 1)];
//    } else {
//        nextItem = [_segmentItems objectAtIndex:(_selectedIndex - 1 <= 0 ? 0 : _selectedIndex - 1)];
//    }
//    CGSize currentSize = [currentItem.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
//    CGSize nextSize = [nextItem.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
//    NSLog(@"%f",currentSize.width - nextSize.width);
//    self.indicatorView.vWidth += (currentSize.width - nextSize.width) * (offset / CGRectGetWidth([UIScreen mainScreen].bounds));
//
//    self.indicatorView.vCenterX += _buttonWidth * (offset / CGRectGetWidth([UIScreen mainScreen].bounds));
//
//    NSInteger currentIndex = (NSInteger)((self.indicatorView.vCenterX + _buttonWidth * 0.5) / _buttonWidth);
//    
//    if (currentIndex < 0) {
//        currentIndex = 0;
//    } else if(currentIndex > self.segmentItems.count - 1) {
//        currentIndex = self.segmentItems.count - 1;
//    }
//    
//    if (currentIndex != _selectedIndex) {
//        [self setSelectedIndex:currentIndex animated:NO];
//    }
    
    // 点击和动画的时候不需要设置
    if (_isAniming || self.segmentItems.count == 0) return;
    
    // 获取偏移量
    CGFloat offsetX = offset;
    
    // 获取左边角标
    NSInteger leftIndex = offsetX / YZScreenW;
    
    // 左边按钮
    UIButton *leftLabel = self.segmentItems[leftIndex];
    
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 右边按钮
    UIButton *rightLabel = nil;
    
    if (rightIndex < self.segmentItems.count) {
        rightLabel = self.segmentItems[rightIndex];
    }
    
    // 字体放大
    [self setUpTitleScaleWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置下标偏移
    if (_isDelayScroll == NO) { // 延迟滚动，不需要移动下标
        
        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    }
    
    // 设置遮盖偏移
    [self setUpCoverOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置标题渐变
    [self setUpTitleColorGradientWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
//     记录上一次的偏移量
    _lastOffsetX = offsetX;
}

#pragma mark - private

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated{
    [self setSelectedIndex:index animated:animated callBack:NO];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated callBack:(BOOL)callBack{
    self.selectedIndex = index;
    if (self.selectedBlock && callBack) {
        self.selectedBlock(self, index);
    }
    [self moveToIndex:index animated:animated];
}

- (void)moveToIndex:(NSInteger)index animated:(BOOL)animated{
    
//    [UIView animateWithDuration:animated ? (_animationDuration) : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (index < self.segmentItems.count) {
            UIButton *button = [self.segmentItems objectAtIndex:index];
            
            if (_itemWidth && self.contentSize.width > CGRectGetWidth([UIScreen mainScreen].bounds)) {
                CGFloat offsetX = CGRectGetMidX(button.frame) - CGRectGetWidth([UIScreen mainScreen].bounds) * 0.5;
                if (offsetX < 0) {
                    offsetX = 0;
                }
                CGFloat maxOffsetX = self.contentSize.width - CGRectGetWidth([UIScreen mainScreen].bounds);
                if (maxOffsetX < 0) {
                    maxOffsetX = 0;
                }
                if (offsetX > maxOffsetX) {
                    offsetX = maxOffsetX;
                }
                [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
            }
//            CGFloat width = _itemWidth && (_itemWidth * self.segmentItems.count > CGRectGetWidth([UIScreen mainScreen].bounds)) ? _itemWidth : CGRectGetWidth(self.frame) / self.segmentItems.count;
            [self redrawButtons];
            
            if (self.indicatorSizeMatchesTitle) {
//                CGSize size = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
//                self.indicatorView.frame = CGRectMake(self.vLeft, self.frame.size.height - self.indicatorHeight,size.width, self.indicatorHeight);
//                self.indicatorView.vWidth = size.width;
            } else {
//                self.indicatorView.vWidth = button.frame.size.width;
//                self.indicatorView.frame = CGRectMake(self.vLeft, self.frame.size.height - self.indicatorHeight, button.frame.size.width, self.indicatorHeight);
            }
        }
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)redrawComponents {
    [self redrawButtons];
    
    if (self.segmentItems.count > 0) {
        [self moveToIndex:_selectedIndex animated:false];
    }
}

- (void)redrawButtons {
    if (self.segmentItems.count == 0) {
        return;
    }
    
    CGFloat width = _buttonWidth;
    CGFloat heigth = CGRectGetHeight(self.frame) - self.indicatorHeight;
    
    if (_itemWidth) {
        self.contentSize = CGSizeMake(width * self.segmentItems.count, CGRectGetHeight(self.frame));
        self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 1, width * self.segmentItems.count, 1);
    }
    
    [self.segmentItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.frame = CGRectMake(width * idx, 0, width, heigth);
        [item setTitleColor:(idx == self.selectedIndex) ? self.selectedTextColor : self.textColor forState:UIControlStateNormal];
        item.titleLabel.font = (idx == self.selectedIndex) ? self.selectedFont : self.normalFont;
    }];
}

- (void)addButtonsWithTitles:(NSArray <NSString *> *)titles  {
    [self.segmentItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.segmentItems removeAllObjects];
    
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = self.normalFont;
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = idx;
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.segmentItems addObject:button];
        [self addSubview:button];
        [self addSubview:self.indicatorView];
    }];
}

- (void)buttonSelected:(UIButton *)btn {
//    if (btn.tag == self.selectedIndex) {
//        return;
//    }
//    [self setSelectedIndex:btn.tag animated:YES callBack:YES];
    // 记录是否点击标题
    _isClickTitle = YES;
    
    // 获取对应标题label
    UIButton *label = btn;
    
    // 获取当前角标
    NSInteger i = label.tag;
    
    // 选中label
    [self selectLabel:label];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = i * YZScreenW;
    
//    self.contentOffset = CGPointMake(offsetX, 0);
    
    // 记录上一次偏移量,因为点击的时候不会调用scrollView代理记录，因此需要主动记录
    _lastOffsetX = offsetX;
    
    // 添加控制器
    //    UIViewController *vc = self.childViewControllers[i];
    
    //    // 判断控制器的view有没有加载，没有就加载，加载完在发送通知
    //    if (vc.view) {
    //        // 发出通知点击标题通知
    //        [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote  object:vc];
    //
    //        // 发出重复点击标题通知
    //        if (_selIndex == i) {
    //            [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewRepeatClickTitleNote object:vc];
    //        }
    //    }
    
    _selIndex = i;
    
    // 点击事件处理完成
    _isClickTitle = NO;
}

#pragma mark - setter

- (void)setItemWidth:(CGFloat)itemWidth {
    _itemWidth = itemWidth;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self redrawComponents];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    [self redrawComponents];
}

- (void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont;
    [self redrawComponents];
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont;
    [self redrawComponents];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.indicatorView.backgroundColor = indicatorColor;
}

- (void)setIndicatorSizeMatchesTitle:(BOOL)indicatorSizeMatchesTitle {
    _indicatorSizeMatchesTitle = indicatorSizeMatchesTitle;
    [self redrawComponents];
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    [self redrawComponents];
}

- (NSMutableArray *)segmentItems{
    if (!_segmentItems) {
        _segmentItems = [[NSMutableArray alloc]init];
    }
    return _segmentItems;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, CGRectGetWidth([UIScreen mainScreen].bounds), 1)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
    return _bottomLine;
}

- (void)setShowBottomLine:(BOOL)showBottomLine {
    _showBottomLine = showBottomLine;
    if (showBottomLine) {
        [self insertSubview:self.bottomLine atIndex:0];
    } else {
        [self.bottomLine removeFromSuperview];
    }
}

@end
