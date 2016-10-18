import XCTest

@testable import OsusumeLunch

class NavigationRouterTests: XCTestCase {
    var navigationRouter: NavigationRouter!
    var rootNavigationController: UINavigationController!

    override func setUp() {
        super.setUp()

        self.rootNavigationController = UINavigationController()
        self.navigationRouter = NavigationRouter(
            navigationController: rootNavigationController
        )
    }
    
    func test_setScreen_showsRecommendationScreen() {
        let recommendationScreen = RecommendationViewController(router: self.navigationRouter)
        navigationRouter.setScreen(viewController: recommendationScreen, animated: false)

        XCTAssertTrue(self.rootNavigationController.topViewController is RecommendationViewController)
    }

    func test_showScreenAsModal_showsRestaurantScreenAsModal() {
        configureUIWindowWithRootViewController()

        let restaurantsScreen = RestaurantTableViewController(router: self.navigationRouter)
        navigationRouter.showScreenAsModal(viewController: restaurantsScreen, animated: false)

        let restaurantsNavController = rootNavigationController.presentedViewController as? UINavigationController

        XCTAssertTrue(restaurantsNavController?.topViewController is RestaurantTableViewController)
    }

    func test_dismissModal_dismissCurrentNavigationController() {
        configureUIWindowWithRootViewController()

        let modalNavController = UINavigationController(rootViewController: UIViewController())
        rootNavigationController.present(
            modalNavController,
            animated: false,
            completion: nil
        )

        let presentedNavController = rootNavigationController.presentedViewController as? UINavigationController
        XCTAssertNotNil(presentedNavController?.topViewController)

        navigationRouter.dismissModal(navigationController: modalNavController, animated: false)

        RunLoop.osu_advance(by: 1)
        XCTAssertNil(self.rootNavigationController.presentedViewController)
    }

    func configureUIWindowWithRootViewController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
}

extension RunLoop {
    static func osu_advance(by timeInterval: TimeInterval = 0.01) {
        let stopDate = NSDate().addingTimeInterval(timeInterval)
        main.run(until: stopDate as Date)
    }
}