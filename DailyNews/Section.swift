//
//  Section.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

@objcMembers class Section: Object, Decodable {
    dynamic var displayName = ""
    dynamic var section = ""

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case section
    }
}

class SectionsResult: Object, Decodable {
    @objc dynamic var copyright = ""
    @objc dynamic var status = ""
    @objc dynamic var numResults = 0
    var sections = List<Section>()

    enum CodingKeys: String, CodingKey {
        case copyright, status
        case numResults = "num_results"
        case sections = "results"
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        copyright = try container.decode(String.self, forKey: .copyright)
        status = try container.decode(String.self, forKey: .status)
        numResults = try container.decode(Int.self, forKey: .numResults)
        let sectionArray = try container.decode([Section].self, forKey: .sections)
        sections.append(objectsIn: sectionArray)
    }
}
