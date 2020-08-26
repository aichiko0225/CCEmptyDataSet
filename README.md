# CCEmptyDataSet

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CCEmptyDataSet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CCEmptyDataSet'
```

## Author

[ash](http://ashless.cc:3333/)
</br>
aichiko66@163.com

## License

CCEmptyDataSet is available under the MIT license. See the LICENSE file for more info.

### UIScrollView 的空视图展示

这个功能其实已经有一个很优秀的库了
[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/tree/master/DZNEmptyDataSet)  

我重新优化了文件结构，加入了maskView的功能

新增两个代理方法

```objc

/**
return YES to display MaskView
*/
- (BOOL)showMaskViewForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

/**
 Provides 5 empty view display scenarios.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 * implementation delegate other EmptyDataSetSource will be invalid.
 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟
 */
- (EmptyDataSetType)showTypeForEmptyDataSet:(UIScrollView * _Nullable)scrollView;

```

可以通过设置`EmptyDataSetType`来快速设置空视图的样式，设置`EmptyDataSetType`后`EmptyDataSetSource`的代理方法将会失效。

另外一个则是会在空视图上面默认加入一个`maskView`，重新获取`BOOL`的时机与空视图的时机一致。

### 使用方法

其他的基础请参考[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/tree/master/DZNEmptyDataSet)
