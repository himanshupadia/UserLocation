//
//  TravelledHistory.swift
//  UserLocation
//
//  Created by Himanshu H. Padia on 20/11/17.
//  Copyright © 2017 TechWorld. All rights reserved.
//

import UIKit
import CoreData

class TravelledHistory: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    var tasks: [History] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(getHistoryDate), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.getHistoryDate), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // GET RECORDS
        getHistoryDate()
    }
    
    @objc func getHistoryDate() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<History>(entityName: "History")
        
        // SORT RECORD BASED ON DATE
        let sort = NSSortDescriptor(key: #keyPath(History.historydate), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            tasks = try context.fetch(fetchRequest)
            if tasks.count > 0 {
                lblNoRecord.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                lblNoRecord.isHidden = false
                tableView.isHidden = true
            }
        } catch {
            print("Cannot fetch Expenses")
        }
    }
}

extension TravelledHistory: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.historydate!
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                let task = self.tasks[indexPath.row]
                let context = self.appDelegate.persistentContainer.viewContext
                context.delete(task)
                self.appDelegate.saveContext()
                do {
                    self.tasks = try context.fetch(History.fetchRequest())
                    if self.tasks.count > 0 {
                        self.lblNoRecord.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    } else {
                        self.lblNoRecord.isHidden = false
                        self.tableView.isHidden = true
                    }
                }
                catch {
                    print("Fetching Failed")
                }
                tableView.reloadData()
            })
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

