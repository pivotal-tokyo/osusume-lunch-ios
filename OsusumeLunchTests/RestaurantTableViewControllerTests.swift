import XCTest
import BrightFutures
import OsusumeNetworking

@testable import OsusumeLunch

class RestaurantTableViewControllerTests: XCTestCase {
    var restaurantTableViewController: RestaurantTableViewController!
    var promise: Promise<[Restaurant], NSError>!

    let expectedRestaurants: [Restaurant] = [
        Restaurant(name: "Afuri"),
        Restaurant(name: "Butagumi"),
    ]

    override func setUp() {
        super.setUp()

        self.restaurantTableViewController = RestaurantTableViewController()

        let repository = FakeRestaurantRepository()
        self.promise = Promise<[Restaurant], NSError>()

        self.restaurantTableViewController.restaurantRepository = repository
        repository.getAllRestaurantsReturnValue = self.promise
        self.restaurantTableViewController.view.setNeedsLayout()

    }

    func test_didGetAllRestaurantsWhenSuccess() {
        self.promise.success(self.expectedRestaurants)

        let expectation = self.expectation(description: "Wait for async call")

        self.promise.future.onComplete { result in
            expectation.fulfill()

            XCTAssertEqual(self.restaurantTableViewController.restaurants.count, self.expectedRestaurants.count)
            XCTAssertEqual(self.restaurantTableViewController.restaurants, self.expectedRestaurants)
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_didGetAllRestaurantsWhenFailure() {
        self.restaurantTableViewController.restaurants = [Restaurant(name: "Afuri")]

        self.promise.failure(NSError(domain: "RestaurantTableViewController_getAllRestaurants", code: 0, userInfo: nil))

        let expectation = self.expectation(description: "Wait for async call")

        self.promise.future.onComplete { result in
            expectation.fulfill()

            XCTAssertEqual(self.restaurantTableViewController.restaurants.count, 0)
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_tableViewCellsHaveRestaurantData() {
        self.restaurantTableViewController.restaurants = self.expectedRestaurants

        let firstCell = self.restaurantTableViewController.tableView(
            self.restaurantTableViewController.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        ) as! RestaurantWhitelistTableViewCell

        XCTAssertEqual(firstCell.restaurantNameLabel.text, "Afuri")
    }

    func test_tableViewRowCountMatchesRestaurantArrayCount() {
        self.restaurantTableViewController.restaurants = self.expectedRestaurants

        self.restaurantTableViewController.tableView.reloadData()

        XCTAssertEqual(self.restaurantTableViewController.tableView.numberOfRows(inSection: 0), self.expectedRestaurants.count)
    }

    func test_tableViewRowCountMatchesRestaurantArrayCount_afterFetchingRestaurants() {
        self.restaurantTableViewController.restaurants = [Restaurant]()
        self.restaurantTableViewController.tableView.reloadData()
        XCTAssertEqual(self.restaurantTableViewController.tableView.numberOfRows(inSection: 0), 0)

        self.restaurantTableViewController.restaurants = self.expectedRestaurants
        self.restaurantTableViewController.viewWillAppear(false)

        self.promise.success(self.expectedRestaurants)

        let expectation = self.expectation(description: "Wait for async call")

        self.promise.future.onComplete { result in
            expectation.fulfill()

            XCTAssertEqual(self.restaurantTableViewController.tableView.numberOfRows(inSection: 0), self.expectedRestaurants.count)
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_viewDidLoad_registersTableViewCellClass() {
        let cell = restaurantTableViewController.tableView.dequeueReusableCell(
            withIdentifier: String(describing: RestaurantWhitelistTableViewCell.self)
        )

        XCTAssertTrue(cell != nil)
    }
}