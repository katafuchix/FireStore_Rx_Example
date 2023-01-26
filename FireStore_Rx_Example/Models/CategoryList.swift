//
//  CategoryList.swift
//  GooRanking
//
//  Created by cano on 2018/12/15.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class CategoryList {

    let key: String
    let category_id: Int
    let id: Int
    let link: String
    let ranking_link: String
    let title: String
    //let status: Int
    let created_date: Date
    var updated_date: Date
    var published: String
    
    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID

        guard
            let category_id   = document.get("category_id") as? Int,
            let id    = document.get("id") as? Int
            //let status  = document.get("status") as? Int
            else { throw ModelError.parseError }
        self.category_id    = category_id
        self.id             = id
        //self.status         = status
        self.created_date   = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()
        self.updated_date   = (document.get("updated_at") as? Timestamp)?.dateValue() ?? Date()
        self.link           = document.get("link") as? String ?? ""
        self.ranking_link   = document.get("ranking_link") as? String ?? ""
        self.title          = (document.get("name") as? String) ?? ""
        self.published      = (document.get("published") as? String) ?? ""
    }
}

extension CategoryList: Equatable {
    static func == (lhs: CategoryList, rhs: CategoryList) -> Bool {
        return lhs.key == rhs.key &&
            lhs.title == rhs.title
    }
}
