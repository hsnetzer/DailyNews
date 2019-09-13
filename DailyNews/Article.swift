//
//  Article.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import RealmSwift

@objcMembers class Article: Object, Decodable {
    dynamic var slugName = ""
    dynamic var section = ""
    dynamic var subsection = ""
    dynamic var title = ""
    dynamic var abstract = ""
    dynamic var url = ""
    dynamic var byline = ""
    dynamic var thumbnailStandard = ""
    dynamic var updatedDate = Date()
    dynamic var createdDate = Date()
    dynamic var publishedDate = Date()
    dynamic var firstPublishedDate = Date()
    dynamic var materialTypeFacet = ""
    dynamic var kicker = ""
    dynamic var subheadline = ""

    enum CodingKeys: String, CodingKey {
        case slugName = "slug_name"
        case section, subsection, title, abstract, url, byline
        case thumbnailStandard = "thumbnail_standard"
        case updatedDate = "updated_date"
        case createdDate = "created_date"
        case publishedDate = "published_date"
        case firstPublishedDate = "first_published_date"
        case materialTypeFacet = "material_type_facet"
        case kicker, subheadline
    }
}

struct ArticlesResult: Decodable {
    let status, copyright: String
    let numResults: Int
    let results: [Article]

    enum CodingKeys: String, CodingKey {
        case status, copyright
        case numResults = "num_results"
        case results
    }
}
