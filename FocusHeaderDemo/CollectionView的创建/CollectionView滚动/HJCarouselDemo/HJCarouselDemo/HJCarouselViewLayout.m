//
//  HJCarouselViewLayout.m
//  HJCarouselDemo
//
//  Created by haijiao on 15/8/20.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

/*
执行过程：
 另外需要了解的是，在初始化一个UICollectionViewLayout实例后，会有一系列准备方法被自动调用，以保证layout实例的正确。
 首先，-(void)prepareLayout将被调用，默认下该方法什么没做，但是在自己的子类实现中，一般在该方法中设定一些必要的layout的结构和初始需要的参数等。
 之后，-(CGSize) collectionViewContentSize将被调用，以确定collection应该占据的尺寸。注意这里的尺寸不是指可视部分的尺寸，而应该是所有内容所占的尺寸。collectionView的本质是一个scrollView，因此需要这个尺寸来配置滚动行为。
 接下来-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect被调用，这个没什么值得多说的。初始的layout的外观将由该方法返回的UICollectionViewLayoutAttributes来决定。
 另外，在需要更新layout时，需要给当前layout发送 -invalidateLayout，该消息会立即返回，并且预约在下一个loop的时候刷新当前layout，这一点和UIView的setNeedsLayout方法十分类似。在-invalidateLayout后的下一个collectionView的刷新loop中，又会从prepareLayout开始，依次再调用-collectionViewContentSize和-layoutAttributesForElementsInRect来生成更新后的布局。
 
 
*/


#import "HJCarouselViewLayout.h"

#define INTERSPACEPARAM  0.65

@interface HJCarouselViewLayout () {
    CGFloat _viewHeight;
    CGFloat _itemHeight;
}

@property (nonatomic) HJCarouselAnim carouselAnim;

@end

@implementation HJCarouselViewLayout

- (instancetype)initWithAnim:(HJCarouselAnim)anim {
    if (self = [super init]) {
        self.carouselAnim = anim;
    }
    return self;
}
#pragma mark- 未拖动时执行
//1 首先，-(void)prepareLayout将被调用，默认下该方法什么没做，但是在自己的子类实现中，一般在该方法中设定一些必要的layout的结构和初始需要的参数等
- (void)prepareLayout {
    [super prepareLayout];
    if (self.visibleCount < 1) {
        self.visibleCount = 5;
    }
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        _viewHeight = CGRectGetHeight(self.collectionView.frame);
        _itemHeight = self.itemSize.height;
        self.collectionView.contentInset = UIEdgeInsetsMake((_viewHeight - _itemHeight) / 2, 0, (_viewHeight - _itemHeight) / 2, 0);
    } else {
        _viewHeight = CGRectGetWidth(self.collectionView.frame);//320
        _itemHeight = self.itemSize.width;//250
        self.collectionView.contentInset = UIEdgeInsetsMake(0, (_viewHeight - _itemHeight) / 2, 0, (_viewHeight - _itemHeight) / 2);//控制collectionView的contentSize的宽度保持为去除左右offset的宽度，即_itemHeight
    }
}
//2
- (CGSize)collectionViewContentSize {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), cellCount * _itemHeight);
    }
    return CGSizeMake(cellCount * _itemHeight, CGRectGetHeight(self.collectionView.frame));//
}
//3
/*
 返回rect中的所有的元素的布局属性
 返回的是包含UICollectionViewLayoutAttributes的NSArray
 UICollectionViewLayoutAttributes可以是cell，追加视图或装饰视图的信息，通过不同的UICollectionViewLayoutAttributes初始化方法可以得到不同类型的UICollectionViewLayoutAttributes：
 layoutAttributesForCellWithIndexPath:
 layoutAttributesForSupplementaryViewOfKind:withIndexPath:
 layoutAttributesForDecorationViewOfKind:withIndexPath:
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat centerY = (self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentOffset.y : self.collectionView.contentOffset.x) + _viewHeight / 2;//centerY=125,self.collectionView.contentOffset.x=-35
    NSInteger index = centerY / _itemHeight;//*/250
    NSInteger count = (self.visibleCount - 1) / 2;
    NSInteger minIndex = MAX(0, (index - count));//0
    NSInteger maxIndex = MIN((cellCount - 1), (index + count));//2
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = minIndex; i <= maxIndex; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [array addObject:attributes];
    }
    return array;
}
//4 返回对应于indexPath的位置的cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.itemSize;
    
    CGFloat cY = (self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentOffset.y : self.collectionView.contentOffset.x) + _viewHeight / 2;
    CGFloat attributesY = _itemHeight * indexPath.row + _itemHeight / 2;
    attributes.zIndex = -ABS(attributesY - cY);//整数的绝对值ABS,浮点数的时候用fabs。
    
    CGFloat delta = cY - attributesY;
    CGFloat ratio =  - delta / (_itemHeight * 2);
    CGFloat scale = 1 - ABS(delta) / (_itemHeight * 6.0) * cos(ratio * M_PI_4);
    attributes.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat centerY = attributesY;
    switch (self.carouselAnim) {
        case HJCarouselAnimRotary:
            attributes.transform = CGAffineTransformRotate(attributes.transform, - ratio * M_PI_4);
            centerY += sin(ratio * M_PI_2) * _itemHeight / 2;
            break;
        case HJCarouselAnimCarousel:
            centerY = cY + sin(ratio * M_PI_2) * _itemHeight * INTERSPACEPARAM;
            break;
        case HJCarouselAnimCarousel1:
            centerY = cY + sin(ratio * M_PI_2) * _itemHeight * INTERSPACEPARAM;
            if (delta > 0 && delta <= _itemHeight / 2) {
                attributes.transform = CGAffineTransformIdentity;
                CGRect rect = attributes.frame;
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    rect.origin.x = CGRectGetWidth(self.collectionView.frame) / 2 - _itemSize.width * scale / 2;
                    rect.origin.y = centerY - _itemHeight * scale / 2;
                    rect.size.width = _itemSize.width * scale;
                    CGFloat param = delta / (_itemHeight / 2);
                    rect.size.height = _itemHeight * scale * (1 - param) + sin(0.25 * M_PI_2) * _itemHeight * INTERSPACEPARAM * 2 * param;
                } else {
                    rect.origin.x = centerY - _itemHeight * scale / 2;
                    rect.origin.y = CGRectGetHeight(self.collectionView.frame) / 2 - _itemSize.height * scale / 2;
                    rect.size.height = _itemSize.height * scale;
                    CGFloat param = delta / (_itemHeight / 2);
                    rect.size.width = _itemHeight * scale * (1 - param) + sin(0.25 * M_PI_2) * _itemHeight * INTERSPACEPARAM * 2 * param;
                }
                attributes.frame = rect;
                return attributes;
            }
            break;
        case HJCarouselAnimCoverFlow: {
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0/400.0f;
            transform = CATransform3DRotate(transform, ratio * M_PI_4, 1, 0, 0);
            attributes.transform3D = transform;
        }
            break;
        default:
            break;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.frame) / 2, centerY);
    } else {
        attributes.center = CGPointMake(centerY, CGRectGetHeight(self.collectionView.frame) / 2);
    }
    
    return attributes;
}

#pragma mark- 拖动时执行
//1 当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息。
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}
//2
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat index = roundf(((self.scrollDirection == UICollectionViewScrollDirectionVertical ? proposedContentOffset.y : proposedContentOffset.x) + _viewHeight / 2 - _itemHeight / 2) / _itemHeight);
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        proposedContentOffset.y = _itemHeight * index + _itemHeight / 2 - _viewHeight / 2;
    } else {
        proposedContentOffset.x = _itemHeight * index + _itemHeight / 2 - _viewHeight / 2;
    }
    return proposedContentOffset;
}

//返回对应于indexPath的位置的装饰视图的布局属性，如果没有装饰视图可不重载
//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
//    
//}

@end
