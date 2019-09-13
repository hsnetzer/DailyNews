//
//  NetworkingClient.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import Alamofire

struct NetworkingClient {
    let urlSuffix = ".json?api-key=ceRc6imurYC8nJjCaQnFoKFrV4a7kXRj"
    let baseURL = "https://api.nytimes.com/svc/news/v3/content/"

    func getSections(completion: @escaping (SectionsResult?, String) -> Void) {
        let url = baseURL + "section-list" + urlSuffix
        print(url)
        AF.request(url)
            .responseDecodable(decoder: JSONDecoder()) { (response: DataResponse<SectionsResult>) in
                if let res = try? response.result.get() {
                    if res.status == "OK" {
                        completion(res, "OK")
                    } else {
                        completion(res, res.status)
                    }
                } else if let error = response.error {
                    completion(nil, error.localizedDescription)
                }
        }
    }

    func getArticles(_ section: String, offset: Int = 0, completion: @escaping (ArticlesResult?, String) -> Void) {
        var url = baseURL + "all/"
        guard let sec = section.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, "Couldn't encode section")
            return
        }
        url += sec
            .replacingOccurrences(of: "&", with: "%26")
            .replacingOccurrences(of: "/", with: "%2F")
        url += urlSuffix
        if offset >= 20 && offset <= 500 && offset % 20 == 0 {
            print("got offset")
            url += "&offset=\(offset)"
        }
        print(url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        AF.request(url)
            .responseDecodable(decoder: decoder) { (response: DataResponse<ArticlesResult>) in
                
                if let res = try? response.result.get() {
                    if res.status == "OK" {
                        completion(res, "OK")
                    } else {
                        completion(res, res.status)
                    }
                } else if let error = response.error {
                    print(error)
                    completion(nil, error.localizedDescription)
                }
        }
    }
}
