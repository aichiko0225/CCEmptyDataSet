//
//  CCEmptyDataSetType.h
//  CCEmptyDataSet
//
//  Created by ash on 2020/8/27.
//

#import <Foundation/Foundation.h>
@class CCEmptyDataSetView;

NS_ASSUME_NONNULL_BEGIN

/**
 Provides 5 empty view display scenarios.
 Default is EmptyDataSetTypeSearchError, EmptyDataSetTypeSearchNone
 */
typedef NS_ENUM(NSInteger, EmptyDataSetType) {
    
    // for jzt_b2b
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
    
    // other custom
};

/**
 EmptyDataSetType Provider
 You can  set the properties of emptyView by EmptyDataSetType
 */
@interface CCEmptyDataSetTypeProvider : NSObject

/**
 Configure the title image of emptyView and the properties of the button by EmptyDataSetType
 titleLabelString detailLabelString will be replaced returned by CCEmptyDataSetSource
 */
+ (BOOL)configureEmptyViewWithType:(EmptyDataSetType)type emptyView:(CCEmptyDataSetView *)emptyView;

@end

NS_ASSUME_NONNULL_END
