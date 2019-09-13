//
//  ArticlesViewController.swift
//  DailyNews
//
//  Created by Harry Netzer on 9/13/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import UIKit

class ArticlesViewController: UITableViewController {

    var viewModel: ArticlesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        title = viewModel.section.displayName

        loadViewModel()
    }

    func loadViewModel() {
        viewModel.getArticles { message, success in
            guard success else {
                self.articlesFailureAlert(message: message)
                return
            }
            self.tableView.reloadData()
        }
    }

    func articlesFailureAlert(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadViewModel()
        }
        alertView.addAction(retryAction)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.navigationController?.present(alertView, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell

        viewModel.configure(cell: cell, forRow: indexPath)

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
