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
        print("ArticlesVC did load")

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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView.numberOfRows(inSection: section) > 0 else { return nil }

        let view = UITableViewHeaderFooterView()
        view.textLabel?.text = viewModel.headerTitle(forSection: section)
        return view
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsInTableView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsInSection(section)
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
}
