# SAPageViewController

[![Pod Version](https://img.shields.io/cocoapods/v/SAPageViewController.svg?style=flat)](http://cocoapods.org/pods/SAPageViewController)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

`SAPageViewController` is an easy-to-use `UIPageViewController` replacement. This framework is a container view controller that allows you to display multiple view controllers that can be swiped either vertically or horizontally. Unlike UIPageController, SAPageViewController is very simple to use, flexible, and provides a few nice features out of the box.

## Features

* Very quick to implement. Can be configured with as little as one line of code.
* Horizontal or vertical scroll.
* Subclass of `UICollectionViewController`. Swiping feels natural and includes all behaviors in `UICollectionView`, like scroll bounce.
* Incuded custom Page Control. You can create your own page control easily.

## Examples of use
We've used it in a few projects including in the [podcasting app CatoAudio for the Cato Institute](http://savvyapps.com/work/cato-institute).

<img src="https://dl.dropboxusercontent.com/s/fp7aid39bzxeb4y/cato_sapageview.gif" width="320" height="586">

## Installation

SAPageViewController is available through [CocoaPods](http://cocoapods.org (http://cocoapods.org/)). To install
it, simply add the following line to your Podfile:

```ruby
pod "SAPageViewController"
```

## How to use

### Import
```objc
#import "SAPageViewController.h"
```

### Subclass SAPageViewController
To start using `SAPageViewController`, simply create a subclass of it, and set the `viewControllers` property to an array of viewController objects.
```objc
@interface ViewController : SAPageViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	self.viewController = @[[Page1ViewController new], [Page2ViewController new], [Page3ViewController new]];
}
```

### Instantiate
You can instantiate your view controller from a storyboard by using a `UICollectionViewController`, or with code by using either `-init` or `-initWithCollectionViewLayout` with a `UICollectionViewFlowLayout` layout.

By default, the `scrollDirection` on `UICollectionViewFlowLayout` is vertical, you can change this with the `scrollDirection` property of `SAPageViewController`, or directly with the `collectionViewLayout` property of `UICollectionViewController`.

### Configure
`SAPageViewController` works really well on a navigation bar. It can display the current view controller's title, navigation buttons and toolbar items on the navigation bar. You can turn this on/off with these properties `showChildNavigationButtons`, `showChildNavigationTitle`, `showChildToolbarItems`.

### Using the default Page Control
To use a page control like in the example, create a new object of the class `UIPageControlView` and add it to the `pageControl` property of your controller.

You will need to set the `pageIcon` property of your view controllers, or override `-(UIImage *)pageIcon` to return an image. You can do the same with `selectedPageIcon` if you want to provide a different image for the selected controller, but this is optional.

Finally, you have to choose how to display the page control. The default page control was designed to be used in the navigation bar, so you can set it as the `titleView` property of the `navigationItem`. Another option is to use a container view controller, and choosing the placement yourself.

### Using a custom Page Control
If you want to make your own page control, create a new `UIView` subclass that conforms to the `SAPageControlDisplay` protocol.

First you shoud implement `-configureWithViewControllers:`; use this to determine which elements of the view controllers you will display in your view. `SAPageControlView` uses the `pageIcon` and `selectedPageIcon` properties, but you can also use the `title` property, or whatever properties you think are relevant to display. It's recommended that you store the number of controllers in the `itemCount` property as well.

Add the `progress` property, and override the setter to update the view when the view is scrolled. The value that is set to the `progress` property is in the range `[0, itemCount - 1] +- ~0.5`. The reason it goes outside the range is because of the bouncing of the underlying `collectionView`. You can either react to it like `SAPageControlView` does, you can clamp the value to always be inside the range, or just disable the bounce in the `collectionView`.

## Author

Emilio Peláez, emilio.pelaez@savvyapps.com (mailto:emilio.pelaez@savvyapps.com)

## License

SAPageViewController is available under the MIT license. See the LICENSE file for more info.
