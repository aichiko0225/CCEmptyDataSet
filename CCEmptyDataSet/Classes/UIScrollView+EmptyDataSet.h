//
//  UIScrollView+EmptyDataSet.h
//  CCEmptyDataSet
//
//  Created by ash on 2018/3/19.
//  Copyright © 2018年 ash. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CCEmptyDataSetSource;
@protocol CCEmptyDataSetDelegate;

/**
 Provides 5 empty view display scenarios.
 Default is EmptyDataSetTypeSearchError, EmptyDataSetTypeSearchNone
 */
typedef NS_ENUM(NSInteger, EmptyDataSetType) {
    /// carts with button
    EmptyDataSetTypeCarts = 0,
    /// orders without button
    EmptyDataSetTypeOrders,
    /// search no data without button
    EmptyDataSetTypeSearchNone,
    /// search error with button
    EmptyDataSetTypeSearchError,
    /// activity without button
    EmptyDataSetTypeActivity,
    /// counpons without button
    EmptyDataSetTypeCounpons
};


/**
 A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display.
 @discussion It will work automatically, by just conforming to CCEmptyDataSetSource, and returning the data you want to show.
 */
@interface UIScrollView (EmptyDataSet)

/** The empty datasets data source. */
@property (nonatomic, weak, nullable) IBOutlet id<CCEmptyDataSetSource> emptyDataSetSource;
/** The empty datasets delegate. */
@property (nonatomic, weak, nullable) IBOutlet id<CCEmptyDataSetDelegate> emptyDataSetDelegate;
/** YES if any empty dataset is visible. */
@property (nonatomic, readonly, getter = isEmptyDataSetVisible) BOOL emptyDataSetVisible;

- (void)reloadEmptyDataSet;

@end

/**
 The object that acts as the data source of the empty datasets.
 */
@protocol CCEmptyDataSetSource <NSObject>

@optional

- (BOOL)showMaskViewForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/**
 Provides 5 empty view display scenarios.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 * implementation delegate other EmptyDataSetSource will be invalid.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 */
- (EmptyDataSetType)showTypeForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/**
 Asks the data source for the title of the dataset.
 The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
 */
- (nullable NSAttributedString *)titleForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 Asks the data source for the description of the dataset.
 */
- (nullable NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 Asks the data source for the image of the dataset.
 */
- (nullable UIImage *)imageForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 Asks the data source for a tint color of the image dataset. Default is nil.
 */
- (nullable UIColor *)imageTintColorForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 *  Asks the data source for the image animation of the dataset.
 */
- (nullable CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 Asks the data source for the title to be used for the specified button state.
 */
- (nullable NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView * _Nullable)scrollView forState:(UIControlState)state;
/**
 Asks the data source for the image to be used for the specified button state.
 This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
 */
- (nullable UIImage *)buttonImageForEmptyDataSet:(UIScrollView * _Nullable)scrollView forState:(UIControlState)state;
/**
 Asks the data source for a background image to be used for the specified button state.
 There is no default style for this call.
 */
- (nullable UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView * _Nullable)scrollView forState:(UIControlState)state;
/**
 Asks the data source for the background color of the dataset. Default is clear color.
 */
- (nullable UIColor *)backgroundColorForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
- (nullable UIView *)customViewForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/**
 Asks the data source for a offset for vertical and horizontal alignment of the content. Default is CGPointZero.
 */
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView * _Nullable)scrollView;
/**
 Asks the data source for a vertical space between elements. Default is 11 pts.
 */
- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

@end

/**
 The object that acts as the delegate of the empty datasets.
 */
@protocol CCEmptyDataSetDelegate <NSObject>
@optional
/**
 Asks the delegate to know if the empty dataset should fade in when displayed. Default is YES.
 */
- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView * _Nullable)scrollView;
/**
 Asks the delegate to know if the empty dataset should be rendered and displayed. Default is YES.
 */
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView * _Nullable)scrollView;
/**
 Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is NO
 大于0时也显示为空。基本不需要设置
 */
- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView * _Nullable)scrollView;

/**
 Asks the delegate for touch permission. Default is YES.
 */
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView * _Nullable)scrollView;
/**
 Asks the delegate for scroll permission. Default is NO.
 */
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView * _Nullable)scrollView;
/**
 Asks the delegate for image view animation permission. Default is NO.
 */
- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView * _Nullable)scrollView;

/**
 Tells the delegate that the action view was tapped, button was tapped.
*/
- (void)emptyDataSet:(UIScrollView * _Nullable)scrollView didTapView:(UIView * _Nonnull)view;
- (void)emptyDataSet:(UIScrollView * _Nullable)scrollView didTapButton:(UIButton * _Nonnull)button;

/**
 Tells the delegate that the empty data set will appear.
 */
- (void)emptyDataSetWillAppear:(UIScrollView * _Nullable)scrollView;
/**
 Tells the delegate that the empty data set did appear.
 */
- (void)emptyDataSetDidAppear:(UIScrollView * _Nullable)scrollView;

/**
 Tells the delegate that the empty data set will disappear.
 */
- (void)emptyDataSetWillDisappear:(UIScrollView * _Nullable)scrollView;

/**
 Tells the delegate that the empty data set did disappear.
 */
- (void)emptyDataSetDidDisappear:(UIScrollView * _Nullable)scrollView;

@end
