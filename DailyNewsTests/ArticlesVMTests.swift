//
//  ArticlesVMTests.swift
//  DailyNewsTests
//
//  Created by Harry Netzer on 9/14/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import XCTest
import RealmSwift
@testable import DailyNews

class ArticlesVMTests: XCTestCase {
    var viewModel: ArticlesViewModel!
    var dummyArticles = [Article]()
    let realm = try! Realm()
    var wordLines: [String]!
    let articles = 100
    let days = 6

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        setupDictionary()
        viewModel = ArticlesViewModel()
        let section = Section()
        section.displayName = "Arts"
        viewModel.section = section

        for _ in 0..<articles {
            dummyArticles.append(randomArticle(section: "Arts", maxDaysAgo: Double(days-1)))
        }

        try! realm.write {
            realm.add(dummyArticles)
        }

        viewModel.getArticles { message, success in
            guard success else { return }
            print(message)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("tearDown")
//        try! realm.write {
//            realm.delete(dummyArticles)
//        }
    }

    func testSections() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(viewModel.sectionsInTableView(), days)
    }

    func testRows() {
        var rows = 0
        for sec in 0..<viewModel.sectionsInTableView() {
            rows += viewModel.rowsInSection(sec)
        }
        XCTAssertEqual(rows, articles)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func randomArticle(section: String, maxDaysAgo: Double = 6) -> Article {
        let art = Article()
        art.title = randomWords(3)
        art.publishedDate = randomNYDate(maxDaysAgo: maxDaysAgo)
        art.section = section
        return art
    }

    func randomNYDate(maxDaysAgo: Double) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "EST")!
        // Day, month, year right now in New York
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        let sub = Double.random(in: -maxDaysAgo..<1) * 24 * 60 * 60
        return calendar.date(from: components)!.addingTimeInterval(sub)
    }

    func setupDictionary() {
        let bundle = Bundle(for: type(of: self))
        if let wordsFilePath = bundle.path(forResource: "web2", ofType: nil) {
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath)

                self.wordLines = wordsString.components(separatedBy: .newlines)
            } catch { // contentsOfFile throws an error
                print("contentsOfFile throws an error")
            }
        }
    }

    func randomWords(_ count: Int) -> String {
        var randomLine = "The"
        for _ in 0..<count {
            let randomInt = Int.random(in: 0..<wordLines.count)

            randomLine.append(" " + wordLines[randomInt])
        }

        return randomLine
    }
}
