//
//  SectionsViewController.swift
//  DailyNews
//
//  Created by Harry Netzer on 9/13/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import UIKit

class SectionsViewController: UITableViewController {

    let viewModel = SectionsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        tableView.delegate = self

        loadViewModel()
    }

    func loadViewModel() {
        viewModel.getSections { message, success in
            guard success else {
                self.sectionsFailureAlert(message: message)
                return
            }
            self.tableView.reloadData()
        }
    }

    func sectionsFailureAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadViewModel()
        }
        alertView.addAction(retryAction)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.navigationController?.present(alertView, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath) as! SectionCell

        viewModel.configure(cell: cell, forRow: indexPath)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertView = UIAlertController(
                title: "Confirm",
                message: "Deleting this section will delete all of its articles from your device.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.viewModel.deleteRow(atIndexPath: indexPath)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            alertView.addAction(action)
            alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.navigationController?.present(alertView, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        viewModel.moveRow(fromIndexPath: fromIndexPath, toIndexPath: to)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = tableView.indexPathForSelectedRow else { return }
        guard let section = viewModel.section(at: index) else { return }
        guard let dest = segue.destination as? ArticlesViewController else { return }

        let viewModel = ArticlesViewModel()
        viewModel.section = section
        dest.viewModel = viewModel
    }
}
