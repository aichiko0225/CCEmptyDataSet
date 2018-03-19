//
//  UIScrollView+EmptyDataSet.m
//  CCEmptyDataSet
//
//  Created by 赵光飞 on 2018/3/19.
//  Copyright © 2018年 赵光飞. All rights reserved.
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


@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;

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

@interface UIScrollView ()

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
    
    if (([self cc_shouldDisplay] && [self cc_itemsCount] == 0) || [self cc_shouldBeForcedToDisplay]) {
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
    return view!=nil ? view.hidden: NO;
}


#pragma mark - Getters (Private)

- (CCEmptyDataSetView *)emptyDataSetView {
    CCEmptyDataSetView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    
    if (!view) {
        view = [[CCEmptyDataSetView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        
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
    }
    return items;
}

#pragma mark - Data Source Getters

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

- (BOOL)cc_isTouchAllowed
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowTouch:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowTouch:self];
    }
    return YES;
}

- (BOOL)cc_isScrollAllowed
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowScroll:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowScroll:self];
    }
    return NO;
}

- (BOOL)cc_isImageViewAnimateAllowed
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAnimateImageView:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAnimateImageView:self];
    }
    return NO;
}


- (void)cc_willAppear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillAppear:self];
    }
}

- (void)cc_didAppear {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidAppear:self];
    }
}

- (void)cc_willDisappear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillDisappear:self];
    }
}

- (void)cc_didDisappear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidDisappear:self];
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


- (void)setupConstraints {
    
}

- (void)prepareForReuse {
    
}

@end

