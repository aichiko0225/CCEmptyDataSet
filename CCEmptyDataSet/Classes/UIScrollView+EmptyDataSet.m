//
//  UIScrollView+EmptyDataSet.m
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/19.
//  Copyright © 2018年 ash. All rights reserved.
//

#import "UIScrollView+EmptyDataSet.h"
#import <objc/runtime.h>
#import "CCEmptyDataMaskView.h"
#import "CCEmptyDataSetView.h"

#pragma mark - CCWeakObjectContainer
@interface CCWeakObjectContainer : NSObject

@property (nonatomic, readonly, weak) id weakObject;

- (instancetype)initWithWeakObject:(id)object;

@end

@implementation CCWeakObjectContainer

- (instancetype)initWithWeakObject:(id)object
{
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    return self;
}

@end

#pragma mark - UIScrollView+EmptyDataSet

/// 类别不能新建属性。。就只能通过Key来 用runtime的 set object来创建

static char const * const kEmptyDataSetSource = "emptyDataSetSource";
static char const * const kEmptyDataSetDelegate = "emptyDataSetDelegate";
static char const * const kEmptyDataSetView = "emptyDataSetView";
static char const * const kEmptyDataMaskView = "emptyDataMaskView";

#define kEmptyImageViewAnimationKey @"com.ash.emptyDataSet.imageViewAnimation"

@interface UIScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) CCEmptyDataSetView *emptyDataSetView;

/**
 loading view Default Hidden is YES
 */
@property (nonatomic, strong) CCEmptyDataMaskView *emptyDataMaskView;

@end

@implementation UIScrollView (EmptyDataSet)

#pragma mark - Reload APIs (Public)
- (void)reloadEmptyDataSet {
    [self cc_reloadEmptyDataSet];
}

#pragma mark - Reload APIs (Private)

- (void)cc_reloadEmptyDataSet {
    if (![self cc_canDisplay]) {
        return;
    }
    
    long count = [self cc_itemsCount];
    
    if (([self cc_shouldDisplay] && count == 0) || [self cc_shouldBeForcedToDisplay]) {
        [self cc_willAppear];
        CCEmptyDataSetView *view = self.emptyDataSetView;
        // Configure empty dataset fade in display
        view.fadeInOnDisplay = [self cc_shouldFadeIn];
        
        if (!view.superview) {
            // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:view atIndex:0];
            }else {
                [self addSubview:view];
            }
        }
        
        if ([self cc_showMaskView]) {
            self.emptyDataMaskView.hidden = NO;
            if (![self.subviews containsObject:self.emptyDataMaskView]) {
                [self addSubview:self.emptyDataMaskView];
                
//                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.emptyDataMaskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
//                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.emptyDataMaskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
//                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.emptyDataMaskView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
//                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.emptyDataMaskView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
            }
            [self.emptyDataMaskView bringSubviewToFront:view];
        }else {
            self.emptyDataMaskView.hidden = YES;
            [self.emptyDataMaskView removeFromSuperview];
            [self setEmptyDataMaskView:nil];
        }
        
        // Removing view resetting the view and its constraints it very important to guarantee a good state
        [view prepareForReuse];
        
        UIView *customView = [self cc_customView];
        
        if (customView) {
            view.customView = customView;
        }else {
            EmptyDataSetType type = [self cc_emptyDataSetType];
            if (type >= 0) {
                NSArray<NSString *> *imageNames = @[@"cc_carts_", @"cc_orders_", @"cc_search_", @"cc_search_", @"cc_activity_", @"cc_coupons_"];
                NSArray<NSString *> *titles = @[@"购物车空空如也", @"您还没有相关订单", @"没有搜索到商品, 换个搜索词试试", @"网络开小差了, 请刷新重试", @"活动暂未开始，敬请期待", @"暂无优惠券"];
                
                NSAttributedString *titleLabelString = [[NSAttributedString alloc] initWithString:[titles objectAtIndex:type] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                
                UIImage *image = [UIImage cc_imageNamed:[imageNames objectAtIndex:type]];
                
                if (image) {
                    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
                        view.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }
                    else {
                        // iOS 6 fallback: insert code to convert imaged if needed
                        view.imageView.image = image;
                    }
                }
                view.titleLabel.attributedText = titleLabelString;
                
                CGFloat navigationHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
                
                view.verticalOffset = [self cc_verticalOffset] - navigationHeight;
                
                if (type == EmptyDataSetTypeCarts) {
                    view.buttonVerticalSpace = 40;
                    [view.button setTitle:@"去首页逛逛" forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateHighlighted];
                    view.button.titleLabel.font = [UIFont systemFontOfSize:15];
                    view.button.layer.masksToBounds = YES;
                    view.button.layer.cornerRadius = 5.0;
                    view.button.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1].CGColor;
                    view.button.layer.borderWidth = 0.5;
                    view.button.frame = CGRectMake(0, 0, 200, 40);
                    
                }else if (type == EmptyDataSetTypeSearchError) {
                    view.buttonVerticalSpace = 40;
                    
                    [view.button setTitle:@"刷新" forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateHighlighted];
                    view.button.titleLabel.font = [UIFont systemFontOfSize:15];
                    view.button.layer.masksToBounds = YES;
                    view.button.layer.cornerRadius = 5.0;
                    view.button.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1].CGColor;
                    view.button.layer.borderWidth = 0.5;
                    view.button.frame = CGRectMake(0, 0, 200, 40);
                    
                    UIImage *image = [UIImage cc_imageNamed:@"cc_refresh_button"];
                    
                    if (image) {
                        [view.button setImage:image forState:UIControlStateNormal];
                        view.button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
                    }
                }
                
                /// 如果实现了代理，title会覆盖掉原来默认的title显示
                // Get the data from the data source
                NSAttributedString *titleLabelString1 = [self cc_titleLabelString];
                NSAttributedString *detailLabelString = [self cc_detailLabelString];
                
                // Configure title label
                if (titleLabelString1) {
                    view.titleLabel.attributedText = titleLabelString1;
                }
                
                // Configure detail label
                if (detailLabelString) {
                    view.detailLabel.attributedText = detailLabelString;
                }
            }else {
                // Get the data from the data source
                NSAttributedString *titleLabelString = [self cc_titleLabelString];
                NSAttributedString *detailLabelString = [self cc_detailLabelString];
                
                UIImage *buttonImage = [self cc_buttonImageForState:UIControlStateNormal];
                NSAttributedString *buttonTitle = [self cc_buttonTitleForState:UIControlStateNormal];
                
                UIImage *image = [self cc_image];
                UIColor *imageTintColor = [self cc_imageTintColor];
                UIImageRenderingMode renderingMode = imageTintColor ? UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAlwaysOriginal;
                
                view.verticalOffset = [self cc_verticalOffset];
                
                // Configure Image
                if (image) {
                    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
                        view.imageView.image = [image imageWithRenderingMode:renderingMode];
                        view.imageView.tintColor = imageTintColor;
                    }
                    else {
                        // iOS 6 fallback: insert code to convert imaged if needed
                        view.imageView.image = image;
                    }
                }
                
                // Configure title label
                if (titleLabelString) {
                    view.titleLabel.attributedText = titleLabelString;
                }
                
                // Configure detail label
                if (detailLabelString) {
                    view.detailLabel.attributedText = detailLabelString;
                }
                
                // Configure button
                if (buttonImage) {
                    [view.button setImage:buttonImage forState:UIControlStateNormal];
                    [view.button setImage:[self cc_buttonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                } else if (buttonTitle) {
                    [view.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
                    [view.button setAttributedTitle:[self cc_buttonTitleForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                    [view.button setBackgroundImage:[self cc_buttonBackgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
                    [view.button setBackgroundImage:[self cc_buttonBackgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                }
            }
        }
        
        view.backgroundColor = [self cc_dataSetBackgroundColor];
        view.hidden = NO;
        view.clipsToBounds = YES;
        
        // Configure empty dataset userInteraction permission
        view.userInteractionEnabled = [self cc_isTouchAllowed];
        
        [view setupConstraints];
        [UIView performWithoutAnimation:^{
            [view layoutIfNeeded];
        }];
        
        
        // Configure scroll permission
        self.scrollEnabled = [self cc_isScrollAllowed];
        
        // Configure image view animation
        if ([self cc_isImageViewAnimateAllowed])
        {
            CAAnimation *animation = [self cc_imageAnimation];
            
            if (animation) {
                [self.emptyDataSetView.imageView.layer addAnimation:animation forKey:kEmptyImageViewAnimationKey];
            }
        }
        else if ([self.emptyDataSetView.imageView.layer animationForKey:kEmptyImageViewAnimationKey]) {
            [self.emptyDataSetView.imageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
        }
        
        // Notifies that the empty dataset view did appear
        [self cc_didAppear];
        
    }else if (self.isEmptyDataSetVisible) {
        [self cc_invalidate];
    }
}


#pragma mark - Getters (Public)

- (id<CCEmptyDataSetSource>)emptyDataSetSource {
    CCWeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetSource);
    return container.weakObject;
}

- (id<CCEmptyDataSetDelegate>)emptyDataSetDelegate {
    CCWeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetDelegate);
    return container.weakObject;
}

- (BOOL)isEmptyDataSetVisible {
    UIView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    return view!=nil ? !view.hidden: NO;
}


#pragma mark - Getters (Private)
- (CCEmptyDataMaskView *)emptyDataMaskView {
    CCEmptyDataMaskView *view = objc_getAssociatedObject(self, kEmptyDataMaskView);
    if (view == nil) {
        view = [[CCEmptyDataMaskView alloc] initWithFrame:self.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        view.clockwise = NO;
//        view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        view.hidden = YES;
        view.backgroundColor = [UIColor whiteColor];
        
        [self setEmptyDataMaskView:view];
    }
    return view;
}

- (CCEmptyDataSetView *)emptyDataSetView {
    CCEmptyDataSetView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    
    if (!view) {
        view = [[CCEmptyDataSetView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        view.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cc_didTapContentView:)];
        view.tapGesture.delegate = self;
        [view addGestureRecognizer:view.tapGesture];
        
        [self setEmptyDataSetView:view];
    }
    return view;
}

- (BOOL)cc_canDisplay {
    if (self.emptyDataSetSource && [self.emptyDataSetSource conformsToProtocol:@protocol(CCEmptyDataSetSource)]) {
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)cc_showHeaderView {
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        if (tableView.tableHeaderView != nil) {
            CGFloat height = tableView.tableHeaderView.bounds.size.height;
            if (height == 0) {
                height = tableView.tableHeaderView.intrinsicContentSize.height;
            }
            return height > 20;
        }
    }
    return NO;
}

- (NSInteger)cc_itemsCount {
    NSInteger items = 0;
    
    // UIScollView doesn't respond to 'dataSource' so let's exit
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
        return items;
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
        return items;
    }
    return items;
}

#pragma mark - Data Source Getters

- (EmptyDataSetType)cc_emptyDataSetType {
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(showTypeForEmptyDataSet:)]) {
        EmptyDataSetType type = [self.emptyDataSetSource showTypeForEmptyDataSet:self];
        return type;
    }
    return -1;
}


- (NSAttributedString *)cc_titleLabelString
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(titleForEmptyDataSet:)]) {
        NSAttributedString *string = [self.emptyDataSetSource titleForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -titleForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)cc_detailLabelString
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(descriptionForEmptyDataSet:)]) {
        NSAttributedString *string = [self.emptyDataSetSource descriptionForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -descriptionForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (UIImage *)cc_image
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(imageForEmptyDataSet:)]) {
        UIImage *image = [self.emptyDataSetSource imageForEmptyDataSet:self];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -imageForEmptyDataSet:");
        return image;
    }
    return nil;
}

- (CAAnimation *)cc_imageAnimation
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(imageAnimationForEmptyDataSet:)]) {
        CAAnimation *imageAnimation = [self.emptyDataSetSource imageAnimationForEmptyDataSet:self];
        if (imageAnimation) NSAssert([imageAnimation isKindOfClass:[CAAnimation class]], @"You must return a valid CAAnimation object for -imageAnimationForEmptyDataSet:");
        return imageAnimation;
    }
    return nil;
}

- (UIColor *)cc_imageTintColor
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(imageTintColorForEmptyDataSet:)]) {
        UIColor *color = [self.emptyDataSetSource imageTintColorForEmptyDataSet:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -imageTintColorForEmptyDataSet:");
        return color;
    }
    return nil;
}

- (NSAttributedString *)cc_buttonTitleForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonTitleForEmptyDataSet:forState:)]) {
        NSAttributedString *string = [self.emptyDataSetSource buttonTitleForEmptyDataSet:self forState:state];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -buttonTitleForEmptyDataSet:forState:");
        return string;
    }
    return nil;
}

- (UIImage *)cc_buttonImageForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.emptyDataSetSource buttonImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIImage *)cc_buttonBackgroundImageForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonBackgroundImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.emptyDataSetSource buttonBackgroundImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonBackgroundImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIColor *)cc_dataSetBackgroundColor
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(backgroundColorForEmptyDataSet:)]) {
        UIColor *color = [self.emptyDataSetSource backgroundColorForEmptyDataSet:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -backgroundColorForEmptyDataSet:");
        return color;
    }
    return [UIColor whiteColor];
}

- (UIView *)cc_customView {
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(customViewForEmptyDataSet:)]) {
        UIView *view = [self.emptyDataSetSource customViewForEmptyDataSet:self];
        if (view) NSAssert([view isKindOfClass:[UIView class]], @"You must return a valid UIView object for -customViewForEmptyDataSet:");
        return view;
    }
    return nil;
}

- (CGFloat)cc_verticalOffset {
    CGFloat offset = 0.0;
    
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(verticalOffsetForEmptyDataSet:)]) {
        offset = [self.emptyDataSetSource verticalOffsetForEmptyDataSet:self];
    }
    return offset;
}

- (CGFloat)cc_verticalSpace {
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(spaceHeightForEmptyDataSet:)]) {
        return [self.emptyDataSetSource spaceHeightForEmptyDataSet:self];
    }
    return 0.0;
}

- (BOOL)cc_showMaskView {
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(showMaskViewForEmptyDataSet:)]) {
        return [self.emptyDataSetSource showMaskViewForEmptyDataSet:self];
    }
    return NO;
}

#pragma mark - Data Delegate Getters

- (BOOL)cc_shouldDisplay {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldDisplay:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldDisplay:self];
    }
    return YES;
}

- (BOOL)cc_shouldBeForcedToDisplay {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldBeForcedToDisplay:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldBeForcedToDisplay:self];
    }
    return NO;
}

- (BOOL)cc_shouldFadeIn {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldFadeIn:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldFadeIn:self];
    }
    return YES;
}

- (BOOL)cc_isTouchAllowed {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowTouch:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowTouch:self];
    }
    return YES;
}

- (BOOL)cc_isScrollAllowed {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowScroll:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowScroll:self];
    }
    return NO;
}

- (BOOL)cc_isImageViewAnimateAllowed {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAnimateImageView:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAnimateImageView:self];
    }
    return NO;
}


- (void)cc_willAppear {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillAppear:self];
    }
}

- (void)cc_didAppear {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidAppear:self];
    }
}

- (void)cc_willDisappear {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillDisappear:self];
    }
}

- (void)cc_didDisappear {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidDisappear:self];
    }
}


- (void)cc_didTapContentView:(UITapGestureRecognizer *)sender {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapView:)]) {
        [self.emptyDataSetDelegate emptyDataSet:self didTapView:sender.view];
    }
}

- (void)cc_didTapDataButton:(id)sender {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapButton:)]) {
        [self.emptyDataSetDelegate emptyDataSet:self didTapButton:sender];
    }
}

#pragma mark - Setters (Public)

- (void)setEmptyDataSetSource:(id<CCEmptyDataSetSource>)emptyDataSetSource {
    if (!emptyDataSetSource || ![self cc_canDisplay]) {
        [self cc_invalidate];
    }
    
    objc_setAssociatedObject(self, kEmptyDataSetSource, [[CCWeakObjectContainer alloc] initWithWeakObject:emptyDataSetSource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // We add method sizzling for injecting -cc_reloadData implementation to the native -reloadData implementation
    [self swizzleIfPossible:@selector(reloadData)];
    
    // Exclusively for UITableView, we also inject -cc_reloadData to -endUpdates
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (void)setEmptyDataSetDelegate:(id<CCEmptyDataSetDelegate>)emptyDataSetDelegate {
    if (!emptyDataSetDelegate) {
        [self cc_invalidate];
    }
    objc_setAssociatedObject(self, kEmptyDataSetDelegate, [[CCWeakObjectContainer alloc] initWithWeakObject:emptyDataSetDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Setters (Private)

- (void)setEmptyDataSetView:(CCEmptyDataSetView *)emptyDataSetView {
    objc_setAssociatedObject(self, kEmptyDataSetView, emptyDataSetView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEmptyDataMaskView:(CCEmptyDataMaskView *)emptyDataMaskView {
    objc_setAssociatedObject(self, kEmptyDataMaskView, emptyDataMaskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cc_invalidate {
    // Notifies that the empty dataset view will disappear
    [self cc_willDisappear];
    if (self.emptyDataSetView) {
        [self.emptyDataSetView prepareForReuse];
        [self.emptyDataSetView removeFromSuperview];
        
        [self setEmptyDataSetView:nil];
        
        self.emptyDataMaskView.hidden = YES;
        [self.emptyDataMaskView removeFromSuperview];
        [self setEmptyDataMaskView:nil];
    }
    
    self.scrollEnabled = YES;
    
    // Notifies that the empty dataset view did disappear
    [self cc_didDisappear];
}

#pragma mark - Method Swizzling
/// 替换掉reload 方法

static NSMutableDictionary *_impLookupTable;
static NSString *const CCSwizzleInfoPointerKey = @"pointer";
static NSString *const CCSwizzleInfoOwnerKey = @"owner";
static NSString *const CCSwizzleInfoSelectorKey = @"selector";

void cc_original_implementation(id self, SEL _cmd)
{
    Class baseClass = cc_baseClassToSwizzleForTarget(self);
    NSString *key = cc_implementationKey(baseClass, _cmd);
    
    NSDictionary *swizzleInfo = [_impLookupTable objectForKey:key];
    NSValue *impValue = [swizzleInfo valueForKey:CCSwizzleInfoPointerKey];
    
    IMP impPointer = [impValue pointerValue];
    
    // We then inject the additional implementation for reloading the empty dataset
    // Doing it before calling the original implementation does update the 'isEmptyDataSetVisible' flag on time.
    [self cc_reloadEmptyDataSet];
    
    // If found, call original implementation
    if (impPointer) {
        ((void(*)(id, SEL))impPointer)(self,_cmd);
    }
}

Class cc_baseClassToSwizzleForTarget(id target)
{
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    return nil;
}

NSString *cc_implementationKey(Class class, SEL selector)
{
    if (!class || !selector) {
        return nil;
    }
    
    NSString *className = NSStringFromClass([class class]);
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@",className, selectorName];
}

// 替换方法
- (void)swizzleIfPossible:(SEL)selector {
    // Check if the target responds to selector
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    // Create the lookup table
    if (!_impLookupTable) {
        _impLookupTable = [NSMutableDictionary dictionaryWithCapacity:3];// 3 represent the supported base classes
    }
    // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:CCSwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:CCSwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = cc_baseClassToSwizzleForTarget(self);
    NSString *key = cc_implementationKey(baseClass, selector);
    NSValue *impValue = [[_impLookupTable objectForKey:key] objectForKey:CCSwizzleInfoPointerKey];
    
    if (impValue || !key || !baseClass) {
        return;
    }
    
    // Swizzle by injecting additional implementation
    Method method = class_getInstanceMethod((baseClass), selector);
    IMP cc_newImplementation = method_setImplementation(method, (IMP)cc_original_implementation);
    
    // Store the new implementation in the lookup table
    NSDictionary *swizzledInfo = @{CCSwizzleInfoOwnerKey: baseClass,
                                   CCSwizzleInfoSelectorKey: NSStringFromSelector(selector),
                                   CCSwizzleInfoPointerKey: [NSValue valueWithPointer:cc_newImplementation]};
    
    [_impLookupTable setObject:swizzledInfo forKey:key];
}

@end

