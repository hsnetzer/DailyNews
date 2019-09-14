//
//  SectionsViewModel.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

class SectionsViewModel {
    private var sectionsResult = SectionsResult()

    var numberOfRows: Int {
        return sectionsResult.sections.count
    }

    func getSections(completion: @escaping (String, Bool) -> Void) {
        if let sections = sectionsFromRealm() {
            self.sectionsResult = sections
            completion("Got Sections from Realm", true)
            return
        }

        sectionsFromAPI(completion: completion)
    }

    private func sectionsFromRealm() -> SectionsResult? {
        guard let realm = try? Realm() else { return nil }
        guard let rlmSections = realm.objects(SectionsResult.self).first else { return nil }

        return rlmSections
    }

    private func sectionsFromAPI(completion: @escaping (String, Bool) -> Void) {
        NetworkingClient().getSections { sec, message in
            guard message == "OK" else {
                completion(message, false)
                return
            }
            guard let sections = sec else {
                completion(message, false)
                return
            }

            if let admin = sections.sections.first(where: { $0.section == "admin" }) {
                admin.displayName = "All"
                admin.section = "all"
            }

            self.sectionsResult = sections

            if let realm = try? Realm() {
                try! realm.write {
                    realm.add(sections)
                }
            }

            completion("Got Sections from Web", true)
        }
    }

    func section(at indexPath: IndexPath) -> Section? {
        guard sectionsResult.sections.indices.contains(indexPath.row) else { return nil }
        return sectionsResult.sections[indexPath.row]
    }

    func configure(cell: SectionCell, forRow indexPath: IndexPath) {
        cell.displayName.text = sectionsResult.sections[indexPath.row].displayName
    }

    func moveRow(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        if let realm = try? Realm() {
            try! realm.write {
                sectionsResult.sections.swapAt(fromIndexPath.row, toIndexPath.row)
            }
        }
    }

    func deleteRow(atIndexPath: IndexPath) {
        if let realm = try? Realm() {
            let sec = sectionsResult.sections[atIndexPath.row]
            let articles = realm.objects(Article.self).filter("section == %@", sec.displayName)
            try! realm.write {
                realm.delete(sec)
                realm.delete(articles)
            }
        }
    }
}
