//
//  ArticlesViewModel.swift
//  DailyNews
//
//  Created by Harry Netzer on 9/13/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

class ArticlesViewModel {
    private var articles = [Article]()
    var section: Section!
    var calendar = Calendar(identifier: .gregorian)
    let today = Date()

    var numberOfRows: Int {
        return articles.count
    }

    // Get articles from Realm if we have one from today. Otherwise, check web for new articles
    func getArticles(completion: @escaping (String, Bool) -> Void) {
        if let articles = articlesFromRealm() {
            self.articles = articles

            if let latest = articles.first {
                if calendar.isDate(latest.publishedDate, inSameDayAs: today) {
                    // We have an article from today in realm
                    completion("Got Articles from Realm", true)
                    return
                }
            }
        }

        articlesFromAPI(completion: completion)
    }

    private func articlesFromRealm() -> [Article]? {
        guard let realm = try? Realm() else { return nil }

        let articles = realm.objects(Article.self)
        guard articles.count > 0 else { return nil }

        return Array(articles)
    }

    // Fetch articles from the web until we have all from today
    private func articlesFromAPI(offset: Int = 0, completion: @escaping (String, Bool) -> Void) {
        NetworkingClient().getArticles(section.section, offset: offset) { res, message in
            guard message == "OK" else {
                completion(message, false)
                return
            }
            guard let articles = res?.results else {
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
                self.articlesFromAPI(offset: offset + 20, completion: completion)
            } else {
                let todayArticles = articles.filter {
                    self.calendar.isDate($0.publishedDate, inSameDayAs: self.today)
                }
                self.addArticles(todayArticles)
                completion("Got all Articles from Web", true)
            }
        }
    }

    func addArticles(_ articles: [Article]) {
        self.articles.append(contentsOf: articles)

        if let realm = try? Realm() {
            try! realm.write {
                realm.add(articles)
            }
        }
    }

    func configure(cell: ArticleCell, forRow indexPath: IndexPath) {
        cell.headline.text = articles[indexPath.row].title
    }

    func didSelectRowAt(_ indexPath: IndexPath) {
        if let url = URL(string: articles[indexPath.row].url) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                print("cant open url")
            }
        }
    }
}
