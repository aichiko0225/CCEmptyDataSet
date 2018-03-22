//
//  UIScrollView+EmptyDataSet.m
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/19.
//  Copyright © 2018年 ash. All rights reserved.
//

#import "UIScrollView+EmptyDataSet.h"
#import <objc/runtime.h>

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

@interface CCEmptyDataSetView: UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;

/**
 When need custom constraints space - button to label
 */
@property (nonatomic, assign) CGFloat buttonVerticalSpace;

@property (nonatomic, assign) BOOL fadeInOnDisplay;

- (void)setupConstraints;
- (void)prepareForReuse;

@end

#pragma mark - UIScrollView+EmptyDataSet

/// 类别不能新建属性。。就只能通过Key来 用runtime的 set object来创建

static char const * const kEmptyDataSetSource = "emptyDataSetSource";
static char const * const kEmptyDataSetDelegate = "emptyDataSetDelegate";
static char const * const kEmptyDataSetView = "emptyDataSetView";

#define kEmptyImageViewAnimationKey @"com.ash.emptyDataSet.imageViewAnimation"

@interface UIScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) CCEmptyDataSetView *emptyDataSetView;

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
        
        // Removing view resetting the view and its constraints it very important to guarantee a good state
        [view prepareForReuse];
        
        UIView *customView = [self cc_customView];
        
        if (customView) {
            view.customView = customView;
        }else {
            EmptyDataSetType type = [self cc_emptyDataSetType];
            if (type >= 0) {
                NSArray<NSString *> *imageNames = @[@"cc_carts", @"cc_orders", @"cc_search_none", @"cc_search_refresh", @"cc_activity"];
                NSArray<NSString *> *titles = @[@"购物车空空如也", @"您还没有相关订单", @"没有搜索到商品, 换个搜索词试试", @"网络开小差了, 请刷新重试", @"暂无活动信息"];
                
                NSAttributedString *titleLabelString = [[NSAttributedString alloc] initWithString:[titles objectAtIndex:type] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                
                NSString *path = [[NSBundle mainBundle] pathForResource:@"CCEmptyDataSet" ofType:@"bundle"];
                NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", [imageNames objectAtIndex:type]]];
                
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                
                if (image == nil) {
                   image = [UIImage imageNamed:[imageNames objectAtIndex:type]];
                }

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
                
                view.verticalOffset = -navigationHeight;
                
                view.verticalSpace = 30;
                
                
                if (type == EmptyDataSetTypeCarts) {
                    view.buttonVerticalSpace = 60;
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
                    view.buttonVerticalSpace = 60;
                    
                    [view.button setTitle:@"刷新" forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
                    [view.button setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateHighlighted];
                    view.button.titleLabel.font = [UIFont systemFontOfSize:15];
                    view.button.layer.masksToBounds = YES;
                    view.button.layer.cornerRadius = 5.0;
                    view.button.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1].CGColor;
                    view.button.layer.borderWidth = 0.5;
                    view.button.frame = CGRectMake(0, 0, 200, 40);
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"CCEmptyDataSet" ofType:@"bundle"];
                    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", @"cc_refresh_button"]];
                    
                    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

                    if (image == nil) {
                        image = [UIImage imageNamed:@"cc_refresh_button"];
                    }
                    
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
        [self cc_didAppear];    }else if (self.isEmptyDataSetVisible) {
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
    return [UIColor clearColor];
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

- (void)cc_invalidate {
    // Notifies that the empty dataset view will disappear
    [self cc_willDisappear];
    if (self.emptyDataSetView) {
        [self.emptyDataSetView prepareForReuse];
        [self.emptyDataSetView removeFromSuperview];
        
        [self setEmptyDataSetView:nil];
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

#pragma mark - CCEmptyDataSetView

@interface CCEmptyDataSetView ()

@end

@implementation CCEmptyDataSetView
// 生成set 方法
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel, detailLabel = _detailLabel, imageView = _imageView, button = _button;
#pragma mark - Initialization Methods

- (instancetype)init {
    self =  [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview {
    CGRect superviewBounds = self.superview.bounds;
    self.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
    
    void(^fadeInBlock)(void) = ^{_contentView.alpha = 1.0;};
    
    if (self.fadeInOnDisplay) {
        [UIView animateWithDuration:0.25
                         animations:fadeInBlock
                         completion:NULL];
    } else {
        fadeInBlock();
    }
}

#pragma mark - Action Methods

- (void)didTapButton:(UIButton *)sender {
    SEL selector = NSSelectorFromString(@"cc_didTapDataButton:");
    
    if ([self.superview respondsToSelector:selector]) {
        [self.superview performSelector:selector withObject:sender afterDelay:0.0f];
    }
}

- (void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
    [_contentView removeConstraints:_contentView.constraints];
}

- (void)prepareForReuse
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _titleLabel = nil;
    _detailLabel = nil;
    _imageView = nil;
    _button = nil;
    _customView = nil;
    
    [self removeAllConstraints];
}

#pragma mark - Getters

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = YES;
        _contentView.alpha = 0;
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = NO;
        _imageView.accessibilityIdentifier = @"empty set background image";
        [_contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:27];
        _titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.accessibilityIdentifier = @"empty set title";
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.backgroundColor = [UIColor clearColor];
        
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        _detailLabel.accessibilityIdentifier = @"empty set detail label";
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor clearColor];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.accessibilityIdentifier = @"empty set button";
        
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_button];
    }
    return _button;
}

- (BOOL)canShowImage {
    return (_imageView.image && _imageView.superview);
}

- (BOOL)canShowTitle {
    return (_titleLabel.attributedText.string.length > 0 && _titleLabel.superview);
}

- (BOOL)canShowDetail {
    return (_detailLabel.attributedText.string.length > 0 && _detailLabel.superview);
}

- (BOOL)canShowButton {
    if ([_button attributedTitleForState:UIControlStateNormal].string.length > 0 || [_button imageForState:UIControlStateNormal]) {
        return (_button.superview != nil);
    }
    if ([_button titleForState:UIControlStateNormal].length > 0 || [_button imageForState:UIControlStateNormal]) {
        return (_button.superview != nil);
    }
    return NO;
}

#pragma mark - Setters

- (void)setCustomView:(UIView *)view {
    if (!view) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = view;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_customView];
}

#pragma mark - Auto-Layout Configuration
- (void)setupConstraints {
    // First, configure the content view constaints
    // The content view must alway be centered to its superview
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [self addConstraint:centerXConstraint];
    [self addConstraint:centerYConstraint];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
    /// 不能定义contentView的高度，需要让他根据内部的约束来自动变化高度
    
    // When a custom offset is available, we adjust the vertical constraints' constants
    if (self.verticalOffset != 0 && self.constraints.count > 0) {
        centerYConstraint.constant = self.verticalOffset;
    }
    
    // If applicable, set the custom view's constraints
    if (_customView) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView":_customView}]];
    }else {
        CGFloat width = CGRectGetWidth(self.frame) ? : CGRectGetWidth([UIScreen mainScreen].bounds);
        
        CGFloat padding = roundf(width/16.0);
        CGFloat verticalSpace = self.verticalSpace ? : 11.0; // Default is 11 pts
        
        NSMutableArray<NSString *> *subviewStrings = [NSMutableArray array];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        NSDictionary *metrics = @{@"padding": @(padding)};
        
        // Assign the image view's horizontal constraints
        if (_imageView.superview) {
            
            [subviewStrings addObject:@"imageView"];
            views[[subviewStrings lastObject]] = _imageView;
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        }
        
        // Assign the title label's horizontal constraints
        if ([self canShowTitle]) {
            
            [subviewStrings addObject:@"titleLabel"];
            views[[subviewStrings lastObject]] = _titleLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[titleLabel(>=0)]-(padding@750)-|" options:0 metrics:metrics views:views]];
        } else {
            // or removes from its superview
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        
        
        // Assign the detail label's horizontal constraints
        if ([self canShowDetail]) {
            
            [subviewStrings addObject:@"detailLabel"];
            views[[subviewStrings lastObject]] = _detailLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[detailLabel(>=0)]-(padding@750)-|" options:0 metrics:metrics views:views]];
        } else {
            // or removes from its superview
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        
        // Assign the button's horizontal constraints
        if ([self canShowButton]) {
            
            [subviewStrings addObject:@"button"];
            views[[subviewStrings lastObject]] = _button;
            if (_button.frame.size.width > 0 && _button.frame.size.height > 0) {
                CGFloat width = _button.frame.size.width;
                CGFloat height = _button.frame.size.height;
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[button(==%g)]", width] options:0 metrics:metrics views:views]];
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[button(==%g)]", height] options:0 metrics:metrics views:views]];
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            }else {
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding@750)-[button(>=0)]-(padding@750)-|" options:0 metrics:metrics views:views]];
            }
        } else {
            // or removes from its superview
            [_button removeFromSuperview];
            _button = nil;
        }
        
        NSMutableString *verticalFormat = [[NSMutableString alloc] init];
        
        // Build a dynamic string format for the vertical constraints, adding a margin between each element. Default is 11 pts.
        for (int i = 0; i < subviewStrings.count; i++) {
            
            NSString *string = subviewStrings[i];
            [verticalFormat appendFormat:@"[%@]", string];
            
            if (i < subviewStrings.count-1) {
                if (_buttonVerticalSpace > 0 && [[subviewStrings lastObject] isEqualToString:@"button"] &&
                    i == subviewStrings.count-2) {
                    [verticalFormat appendFormat:@"-(%.f@750)-", _buttonVerticalSpace];
                }else {
                    [verticalFormat appendFormat:@"-(%.f@750)-", verticalSpace];
                }
            }
        }
        
        // Assign the vertical constraints to the content view
        if (verticalFormat.length > 0) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@|", verticalFormat] options:0 metrics:metrics views:views]];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if ([hitView isKindOfClass:[UIControl class]]) {
        return hitView;
    }
    
    if ([hitView isEqual:_contentView] || [hitView isEqual:_customView]) {
        return hitView;
    }
    return nil;
}

@end

