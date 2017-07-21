//
//  ViewController.swift
//  realmToDoList-Swift
//
//  Created by Matheus on 18/07/17.
//  Copyright © 2017 Matheus Tavares. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift
import SwipyCell

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, SwipyCellDelegate,UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    var selectedTask = Task()

    var searchController: UISearchController!
    var selectedScope = 0
    var notificationToken: NotificationToken?

    var message = ""
    var refreshControl: UIRefreshControl?

    var setupView = true

    let scopeTitleList = ["To Do", "Done", "All"]
    
    var tableViewBigHeader = 88, tableViewSmallHeader = 44

    private var items: Results<Task> {

        return searchController.isActive ? searchedTasks[selectedScope] : taskList[selectedScope]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRealm()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(self.message != "") {
            showToast(self.message)
            self.message = ""
        }
    }

    func searchScopeOn(){
        self.searchController.searchBar.showsScopeBar = true
        
        self.searchController.searchBar.sizeToFit()
        self.searchController.loadView()
        self.tableView.reloadData()
    }
    

    func viewSetup() {

        searchController = UISearchController(searchResultsController: nil)

        self.definesPresentationContext = false
        searchController.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.isActive = false
        searchController.searchBar.scopeButtonTitles = scopeTitleList
        
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.placeholder = "Search Task"
        searchController.searchBar.barTintColor = lightBlueColor
        searchController.searchBar.tintColor = .white
        
        
        
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        let footerView = UIView(frame: CGRect.zero)
        footerView.backgroundColor = .white

        self.tableView.tableFooterView = footerView
        self.tableView.backgroundColor = .white

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120.0
        
    }


    func setupNotifications(_ result: Results<Task>) -> NotificationToken {

        return result.addNotificationBlock { [unowned self] changes in
            switch changes {
            case .initial:
                searchedTasks.removeAll(keepingCapacity: false)
                searchedTasks = taskList
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                searchedTasks.removeAll(keepingCapacity: false)
                searchedTasks = taskList
                
                if(self.items.count==0){
                    self.tableView.reloadData()
                }else{
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                    self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                    
                    if(self.selectedScope==2){
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                    }else{
                    self.tableView.deleteRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .fade)
                    }
                    
                    self.tableView.endUpdates()

                }
                break
            case .error(let error):
                fatalError(String(describing: error))
            }
        }
    }

    func setupRealm() {
        realm = try! Realm()

        taskList.append(realm.objects(Task.self).filter("completed == false"))
        taskList.append(realm.objects(Task.self).filter("completed == true"))
        taskList.append(realm.objects(Task.self))

        searchedTasks.removeAll(keepingCapacity: false)

        searchedTasks = taskList

        for i in 0...2 {
            self.notificationToken = self.setupNotifications(taskList[i])
        }
        if(setupView) {
            self.viewSetup()
            self.setupView = false
        }
    }

    //    MARK: Swipy Delegates

    // When the user starts swiping the cell this method is called
    func swipyCellDidStartSwiping(_ cell: SwipyCell) {

    }

    // When the user ends swiping the cell this method is called
    func swipyCellDidFinishSwiping(_ cell: SwipyCell, atState state: SwipyCellState, triggerActivated activated: Bool) {
        //        print("swipe finished - activated: \(activated), state: \(state)")
        cell.swipeToOrigin {
            
        }
    }

    // When the user is dragging, this method is called with the percentage from the border
    func swipyCell(_ cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat, currentState state: SwipyCellState, triggerActivated activated: Bool) {

    }

    //MARK: Search Delegate
    func updateSearchResults(for searchController: UISearchController) {

        if let searchText = searchController.searchBar.text, !searchText.isEmpty {

            var predicate = NSPredicate()

            switch selectedScope {
            case 0:
                predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND completed == false", searchText.lowercased())
                break
            case 1:
                predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND completed == true", searchText.lowercased())
                break
            case 2:
                predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText.lowercased())
                break
            default:
                break
            }

            let array = realm.objects(Task.self).filter(predicate)
            searchedTasks[selectedScope] = array

        } else {
            searchedTasks = taskList
        }

        self.tableView.reloadData()
    }
    
    
   
    func didPresentSearchController(_ searchController: UISearchController) {
        searchScopeOn()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        
        searchScopeOn()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.searchController.resignFirstResponder()
        
       searchScopeOn()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.resignFirstResponder()
//        self.searchController.loadView()
        searchScopeOn()
    }
    
//    func searchbar

    func searchBar(_: UISearchBar, selectedScopeButtonIndexDidChange: Int) {
        self.selectedScope = selectedScopeButtonIndexDidChange
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        let data = searchController.isActive ? searchedTasks : taskList
        let count = items.count
        if(count == 0) {

            let noResultLabel = UILabel(frame: tableView.bounds)
            noResultLabel.textColor = UIColor(white: 60.0 / 255.0, alpha: 1)
            noResultLabel.numberOfLines = 0
            noResultLabel.textAlignment = NSTextAlignment.center
            noResultLabel.font = noResultLabel.font.withSize(14)

            noResultLabel.text = selectedScope == 1 ? "There's no task done!\n Swipe left on a task to complete it!" : "There's no task saved!\n Press the + button to create one!"
            noResultLabel.textColor = lightBlueColor
            noResultLabel.sizeToFit()

            tableView.backgroundView = noResultLabel

            self.tableView.isHidden = false

        } else {

            tableView.backgroundView = nil
        }


        return count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell


        cell.accessoryType = .disclosureIndicator

        let task = items[indexPath.row]

        cell.bind(task)

        cell.delegate = self

        cell.task = task

        var swipeView = UIView()
        var swipeColor = UIColor()
        var message = ""

        if !(cell.task.completed) {
            swipeView = viewWithImageName("check")
            swipeColor = greenColor//UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
            message = "Congratulations! Task Completed!"
        } else {
            swipeView = viewWithImageName("clock")
            swipeColor = .gray
            message = "Maybe later!"
        }



        cell.addSwipeTrigger(forState: .state(0, .left), withMode: .exit, swipeView: swipeView, swipeColor: swipeColor, completion: { cell, trigger, state, mode in

            try! realm.write {
                task.completed = !task.completed

                realm.create(Task.self, value: task, update: true)

            }

            showToast(message)

        })

        cell.addSwipeTrigger(forState: .state(0, .right), withMode: .none, swipeView: viewWithImageName("cross"), swipeColor: redColor, completion: { cell, trigger, state, mode in

            let yesHandler: ((UIAlertAction) -> Void) = { (action) in
                //            DELETE TASK
                try! realm.write {
                    realm.delete(task)
                }
                showToast("Task deleted!")
            }

            let noHandler: ((UIAlertAction) -> Void) = { (action) in
//                cell.swipeToOrigin { }
            }

            presentYesNoAlert(title: "Are you sure you want to delete that Task?", message: " \(task.name) \nWill be deleted forever!", view: self, yesHandler: yesHandler, noHandler: noHandler)

        })

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.selectedTask = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "editTask", sender: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "editTask":

                let task = self.selectedTask

                let destination = segue.destination as! DetailsViewController
                destination.task = task
                destination.isEditingTask = true
                destination.parentView = self
                break

            default:
                break
            }


        }
    }
}


