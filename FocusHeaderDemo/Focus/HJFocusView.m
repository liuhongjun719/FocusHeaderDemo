//
//  FocusView.m
//  SampleDemo
//
//  Created by 123456 on 16/4/5.
//  Copyright © 2016年 vizz. All rights reserved.
//

#import "HJFocusView.h"
#import "FocusCell.h"


static NSString *const FocusCellIdentifier = @"FocusCellIdentifier";

@interface HJFocusView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end
@implementation HJFocusView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[self getFlowLayout]];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.collectionView];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.pagingEnabled = YES;
        [self.collectionView registerNib:[UINib nibWithNibName:@"FocusCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:FocusCellIdentifier];
        [self addSubview:self.pageControl];
        [self setContentOffset];
        
    }
    return self;
}
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((0), self.frame.size.height-20, self.frame.size.width, 20)];
        self.pageControl.numberOfPages = self.imageNames.count - 2;
    }
    return _pageControl;
}
- (UICollectionViewFlowLayout *)getFlowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    return flowLayout;
}
- (NSMutableArray *)imageNames
{
    if (!_imageNames) {
        _imageNames = [NSMutableArray array];
        [_imageNames addObject:@"6"];
        for (NSInteger i = 1; i <= 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"%ld", (long)i];
            [_imageNames addObject:imageName];
        }
        [_imageNames addObject:@"1"];
    }
     
    return _imageNames;
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FocusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FocusCellIdentifier forIndexPath:indexPath];
    
    [cell setImageViewWithImageName:self.imageNames[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustPageWithScrollView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self adjustPageWithScrollView:scrollView];
}


- (void)adjustPageWithScrollView:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / _collectionView.bounds.size.width;
    
    if (index == 0) {
        [scrollView setContentOffset:CGPointMake((_imageNames.count - 2) * _collectionView.bounds.size.width, 0) animated:NO];
        _pageControl.currentPage = _imageNames.count - 2;
    } else if (index == _imageNames.count - 1) {
        [scrollView setContentOffset:CGPointMake(_collectionView.bounds.size.width, 0) animated:NO];
        _pageControl.currentPage = 0;
    } else {
        _pageControl.currentPage = index - 1;
    }
}


#pragma mark- Scroll to selected page
- (void)nextPage
{
    NSInteger index = _collectionView.contentOffset.x / _collectionView.bounds.size.width;
    [_collectionView setContentOffset:CGPointMake(++index * _collectionView.bounds.size.width, 0) animated:YES];
}

- (void)setContentOffset {
    [self.collectionView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:NO];
}
#pragma mark- Set timer
- (void)addTimer
{
    if (self.timer) {
        [self removeTimer];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}



@end
