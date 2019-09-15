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

    // MARK: - Private functions for fetching data from server or Realm

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

            // Remove sections that are deprecated or don't play nice
            let badSections = ["admin", "crosswords & games", "home & garden",
                               "corrections", "podcasts", "guides", "home page",
                               "job market", "lens", "automobiles", "education",
                               "multimedia/photos", "times insider",
                               "universal", "video", "en español"]
            sections.sections = self.removeFrom(list: sections.sections, these: badSections)

            self.sectionsResult = sections

            completion("Got Sections from Web", true)

            if let realm = try? Realm() {
                try! realm.write {
                    realm.add(sections)
                }
            }
        }
    }

    private func removeFrom(list: List<Section>, these: [String]) -> List<Section> {
        let newList = List<Section>()
        for section in list {
            if !these.contains(section.section) {
                newList.append(section)
            }
        }
        return newList
    }

    // MARK: - Public methods

    /// This function gets the sections from Realm if they've already been cached
    /// there. Otherwise, it checks the web for the sections.
    ///
    /// - Parameters:
    ///     - completion: A completion block, marked escaping because API requests are asynchronous.
    ///     - message: A message returned from the server.
    ///     - success: A boolean value representing that the articles were fetched successfuly.
    func getSections(completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        if let sections = sectionsFromRealm() {
            self.sectionsResult = sections
            completion("Got Sections from Realm", true)
            return
        }

        sectionsFromAPI(completion: completion)
    }

    // MARK: Tableview

    /// This function configures a `SectionCell` in the `SectionsViewController`'s `TableView`.
    ///
    /// - Parameters:
    ///     - cell: The `SectionCell` to be configured.
    ///     - forRow: The `IndexPath` of `cell`.
    func configure(cell: SectionCell, forRow indexPath: IndexPath) {
        cell.displayName.text = sectionsResult.sections[indexPath.row].displayName
    }

    /// This function returns the Section at a given index in the tableview.
    ///
    /// - Parameter indexPath: The `IndexPath` of of the Section to return.
    ///
    /// - Returns: The Section at the given IndexPath, or nil.
    func section(at indexPath: IndexPath) -> Section? {
        guard sectionsResult.sections.indices.contains(indexPath.row) else { return nil }
        return sectionsResult.sections[indexPath.row]
    }

    /// This function rearranges the cached array of Sections in Realm in response to the user reordering the tableview.
    ///
    /// - Parameters:
    ///     - fromIndexPath: The old IndexPath of the SectionCell being moved.
    ///     - toIndexPath: The new IndexPath of the SectionCell being moved.
    func moveRow(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        guard let realm = try? Realm() else { return }

        try! realm.write {
            let section = sectionsResult.sections[fromIndexPath.row]
            sectionsResult.sections.remove(at: fromIndexPath.row)
            sectionsResult.sections.insert(section, at: toIndexPath.row)
        }
    }

    /// This function responds to the user deleting a row from the SectionsVC. The Section is deleted
    /// from Realm along with any Articles in that section. Because the sectionsResult property of
    /// this class is a "live" Realm Object, it automatically updates its collection of Sections in
    /// response to the deletion.
    ///
    /// - Parameter atIndexPath: The IndexPath of the SectionCell being deleted.
    func deleteRow(atIndexPath: IndexPath) {
        guard let realm = try? Realm() else { return }

        let sec = sectionsResult.sections[atIndexPath.row]
        let articles = realm.objects(Article.self).filter("section == %@", sec.displayName)
        try! realm.write {
            realm.delete(sec)
            realm.delete(articles)
        }
    }
}
