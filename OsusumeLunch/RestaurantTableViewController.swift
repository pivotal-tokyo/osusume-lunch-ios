import UIKit
import OsusumeNetworking

class RestaurantTableViewController: UITableViewController {

    // MARK: - Properties
    var restaurantRepository: RestaurantRepository = NetworkRestaurantRepository()
    var restaurants: [Restaurant] = [Restaurant]()
    var router: Router
    let cellReuseIdentifier = "restaurantTableViewCell"

    init(router: Router) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavbar()
        self.setToolbar()
        self.tableView.register(
            RestaurantWhitelistTableViewCell.self,
            forCellReuseIdentifier: String(describing: RestaurantWhitelistTableViewCell.self)
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.getAllRestaurants()
    }

    // MARK: - View Setup
    private func setupNavbar() {
        self.navigationItem.title = "Lunch Spots"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.done,
            target: self,
            action: #selector(self.done))
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "done"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(self.showNewRestaurantScreen))
        self.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "add new restaurant"
    }

    private func setToolbar() {
        self.navigationController?.setToolbarHidden(false, animated: false)

        let flexible = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self,
            action: nil
        )

        self.editButtonItem.accessibilityIdentifier = "edit"
        self.setToolbarItems([flexible, self.editButtonItem], animated: false)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantWhitelistTableViewCell.self), for: indexPath) as! RestaurantWhitelistTableViewCell

        cell.setRestaurant(restaurant: self.restaurants[indexPath.row])

        return cell
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let id = restaurants[indexPath.row].id
            self.restaurantRepository.deleteRestaurant(id: id)
            self.restaurants.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
        }
    }

    // MARK: - Action
    private func getAllRestaurants() {
        self.restaurantRepository.getAllRestaurants()
            .onSuccess { restaurants in
                self.restaurants = restaurants
            }
            .onFailure { error in
                self.restaurants.removeAll()
            }
            .onComplete { _ in
                self.tableView.reloadData()
            }
    }

    @objc
    private func showNewRestaurantScreen() {
        self.router.pushScreen(
            viewController: NewRestaurantViewController(router: self.router),
            animated: true
        )
    }

    @objc
    private func done() {
        self.router.dismissModal(navigationController: self.navigationController!, animated: true)
    }
}
