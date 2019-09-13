//
//  SectionsViewModel.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

class SectionsViewModel {
    private var sections = SectionsResult()

    var numberOfRows: Int {
        return sections.results.count
    }

    func getSections(completion: @escaping (String, Bool) -> Void) {
        if let sections = sectionsFromRealm() {
            self.sections = sections
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
            
            if let admin = sections.results.first(where: { $0.section == "admin" }) {
                admin.displayName = "All"
                admin.section = "all"
            }

            self.sections = sections

            if let realm = try? Realm() {
                try! realm.write {
                    realm.add(sections)
                }
            }

            completion("Got Sections from Web", true)
        }
    }

    func section(at indexPath: IndexPath) -> Section? {
        guard sections.results.indices.contains(indexPath.row) else { return nil }
        return sections.results[indexPath.row]
    }

    func configure(cell: SectionCell, forRow indexPath: IndexPath) {
        cell.displayName.text = sections.results[indexPath.row].displayName
    }

    func moveRow(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        if let realm = try? Realm() {
            try! realm.write {
                sections.results.swapAt(fromIndexPath.row, toIndexPath.row)
            }
        }
    }

    func deleteRow(atIndexPath: IndexPath) {
        if let realm = try? Realm() {
            try! realm.write {
                let sec = sections.results[atIndexPath.row]
                sections.results.remove(at: atIndexPath.row)
                realm.delete(sec)
            }
        }
    }
}
