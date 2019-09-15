//
//  ArticlesViewModel.swift
//  DailyNews
//
//  Created by Harry Netzer on 9/13/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

class ArticlesViewModel {
    var section: Section!
    private var calendar = Calendar(identifier: .gregorian)
    private let today: Date
    private var articles = Array(repeating: [Article](), count: 7)

    // MARK: - Public methods

    init() {
        calendar.timeZone = TimeZone(abbreviation: "EST")!
        // Day, month, year right now in New York
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        today = calendar.date(from: components)!
    }

    /// This function gets articles from Realm if we have one from today. Otherwise, check web for new articles
    ///
    /// - Parameters:
    ///     - completion: A completion block.
    ///     - message: A message returned from the server.
    ///     - success: A boolean value representing that the articles were fetched successfuly.
    func getArticles(completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        if let articles = articlesFromRealm() {
            let oldArticles = sortByDay(articles: articles)
            deleteArticlesFromRealm(oldArticles)

            // Check if we already have any articles from today
            if self.articles.first!.count > 0 {

                // We have an article from today from realm
                completion("Got Articles from Realm", true)
                return
            }
        }

        getNewArticlesFromAPI(completion: completion)
    }

    // MARK: Tableview

    /// This function configures an `ArticleCell` in the `ArticlesViewController`'s `TableView`.
    ///
    /// - Parameters:
    ///     - cell: The `ArticleCell` to be configured.
    ///     - forRow: The `IndexPath` of `cell`.
    func configure(cell: ArticleCell, forRow indexPath: IndexPath) {
        guard let index = sectionToIndex(indexPath.section) else { return }

        cell.headline.text = articles[index][indexPath.row].title
    }

    /// This function opens the url of the article that was tapped in the tableview.
    ///
    /// - Parameter indexPath: The `IndexPath` of article that was tapped.
    func didSelectRowAt(_ indexPath: IndexPath) {
        guard let index = sectionToIndex(indexPath.section) else { return }
        guard let url = URL(string: articles[index][indexPath.row].url) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
    }

    /// This function returns the day of the week of a section of the tableview.
    ///
    /// - Parameter forSection: the index of the section.
    ///
    /// - Returns: The name of the day of the week representing that section.
    func headerTitle(forSection: Int) -> String {
        switch forSection {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2:
            let day = calendar.component(.weekday, from: today.addingTimeInterval(-2.0 * 24 * 60 * 60))
            return calendar.weekdaySymbols[day-1]
        case 3:
            let day = calendar.component(.weekday, from: today.addingTimeInterval(-3.0 * 24 * 60 * 60))
            return calendar.weekdaySymbols[day-1]
        case 4:
            let day = calendar.component(.weekday, from: today.addingTimeInterval(-4.0 * 24 * 60 * 60))
            return calendar.weekdaySymbols[day-1]
        case 5:
            let day = calendar.component(.weekday, from: today.addingTimeInterval(-5.0 * 24 * 60 * 60))
            return calendar.weekdaySymbols[day-1]
        case 6:
            let day = calendar.component(.weekday, from: today.addingTimeInterval(-6.0 * 24 * 60 * 60))
            return calendar.weekdaySymbols[day-1]
        default:
            return "Error"
        }
    }

    /// This function returns number of sections in the tableview.
    ///
    /// - Returns: The number of sections that should be displayed.
    func sectionsInTableView() -> Int {
        return articles.reduce(0, { sum, next in
            sum + (next.count > 0 ? 1 : 0)
        })
    }

    /// This function returns the number of rows in a given section.
    ///
    /// - Parameter section: the index of the section.
    ///
    /// - Returns: The number of rows in that section.
    func rowsInSection(_ section: Int) -> Int {
        if let index = sectionToIndex(section) {
            return articles[index].count
        }
        return 0
    }

    // MARK: - Private methods

    // MARK: Populating articles

    private func articlesFromRealm() -> [Article]? {
        guard let realm = try? Realm() else { return nil }

        var articles = realm.objects(Article.self)
        print(articles.count)
        if section.section != "all" {
            articles = articles.filter("section == %@", section.displayName)
        }

        guard articles.count > 0 else { return nil }

        return Array(articles)
    }

    // Fetch articles from the web until we have all from today
    private func getNewArticlesFromAPI(offset: Int = 0, completion: @escaping (String, Bool) -> Void) {
        NetworkingClient().getArticles(section.section, offset: offset) { res, message in
            guard message == "OK" else {
                completion(message, false)
                return
            }
            guard let articles = res?.articles else {
                completion(message, false)
                return
            }
            guard let oldest = articles.last?.publishedDate else {
                completion(message, false)
                return
            }

            if self.calendar.isDate(oldest, inSameDayAs: self.today) {
                self.addArticles(articles)
                completion("Got some of the Articles", true)
                self.getNewArticlesFromAPI(offset: offset + 20, completion: completion)
            } else {
                let todayArticles = articles.filter {
                    self.calendar.isDate($0.publishedDate, inSameDayAs: self.today)
                }
                self.addArticles(todayArticles)
                completion("Got all Articles from Web", true)
            }
        }
    }

    // This function adds an array of articles to Realm and the articles property.
    private func addArticles(_ articles: [Article]) {
        _ = sortByDay(articles: articles)

        if let realm = try? Realm() {
            try! realm.write {
                realm.add(articles)
            }
        }
    }

    /// This function adds articles to the viewmodel's articles property.
    ///
    /// - Parameter articles: An array of articles.
    ///
    /// - Returns: An array of articles that weren't added to the table because they are too old.
    private func sortByDay(articles: [Article]) -> [Article] {
        var oldArticles = [Article]()

        for article in articles {
            let timeIntervalSinceTodayAndPublish = article.publishedDate.timeIntervalSince(today)
            let timeIntervalOfADay = -24.0 * 60 * 60

            switch timeIntervalSinceTodayAndPublish {
            case 0...:
                self.articles[0].append(article)
            case timeIntervalOfADay..<0:
                self.articles[1].append(article)
            case 2*timeIntervalOfADay..<timeIntervalOfADay:
                self.articles[2].append(article)
            case 3*timeIntervalOfADay..<2*timeIntervalOfADay:
                self.articles[3].append(article)
            case 4*timeIntervalOfADay..<3*timeIntervalOfADay:
                self.articles[4].append(article)
            case 5*timeIntervalOfADay..<4*timeIntervalOfADay:
                self.articles[5].append(article)
            case 6*timeIntervalOfADay..<5*timeIntervalOfADay:
                self.articles[6].append(article)
            default:
                print("Skipping old article")
                oldArticles.append(article)
            }
        }

        return oldArticles
    }

    // MARK: Helpers

    private func deleteArticlesFromRealm(_ articles: [Article]) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(articles)
        }
    }

    private func sectionToIndex(_ section: Int) -> Int? {
        var thisSection = -1
        for index in 0..<articles.count {
            if articles[index].count > 0 {
                thisSection += 1
            }
            if thisSection == section { return index }
        }
        return nil
    }
}
