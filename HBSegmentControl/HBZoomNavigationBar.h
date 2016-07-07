//
//  HBZoomNavigationBar.h
//  HBSegmentControl
//
//  Created by 赵鹏 on 16/7/3.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HBZoomNavigationBarDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface HBZoomNavigationBar : UIView

@property (weak, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic, nullable) id<HBZoomNavigationBarDelegate> zoomBarDelegate;

+ (instancetype)navigationBarWithFrame:(CGRect)frame delegate:(nullable id<HBZoomNavigationBarDelegate>)delegate;

@end

@protocol HBZoomNavigationBarDelegate <NSObject>

@optional;
- (void)navigationBar:(HBZoomNavigationBar *)navigationBar didSelecedtedSegmentIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
