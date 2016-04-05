//
//  FocusView.h
//  SampleDemo
//
//  Created by 123456 on 16/4/5.
//  Copyright © 2016年 vizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJFocusView : UIView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imageNames;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPageControl *pageControl;

- (void)addTimer;
-(void)removeTimer;
- (void)setContentOffset;
@end
