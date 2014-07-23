CXSwipeNavigation
=================

CXSwipeNavigation is a series of classes that allows you to swipe vertically between `UITableView` and `UICollectionView`.

#### 1. Build your UITableViewController and UICollectionViewControllers as subclasses of CXSwipeTableViewController and CXSwipeCollectionViewController, respectively.

*MYTableViewController.h*

    @interface MYTableViewController : CXSwipeTableViewController

    // ...

    @end

*MYCollectionViewController.h*

    @interface MYCollectionViewController : CXSwipeCollectionViewController

    // ...

    @end

#### 2. Use CXSwipeNavigationController as your main navigation controller and set the data source.

*MYAppDelegate.m*

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        //...

        self.viewControllers = @[[MYTableViewController alloc] init], [MYTableViewController alloc] init], [MYCollectionViewController alloc] init], [MYCollectionViewController alloc] init]];

        self.navigationController = [[CXApplicationViewController alloc] initWithRootViewController:self.viewControllers.firstObject];
        self.navigationController.dataSource = self;

        //...
    }

#### 3. Implement the methods in CXSwipeNavigationControllerDataSource.

*MYAppDelegate.m*

    - (NSUInteger)numberOfViewControllersForSwipeNavigationController:(CXSwipeNavigationController *)navigationController
    {
        return self.viewControllers.count;
    }

    - (UIViewController *)swipeNavigationController:(CXSwipeNavigationController *)navigationController viewControllerAtIndex:(NSUInteger)index
    {
        return self.viewControllers[index];
    }
