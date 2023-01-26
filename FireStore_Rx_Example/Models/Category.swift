//
//  Category.swift
//  GooRanking
//
//  Created by cano on 2018/12/15.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Category {

    let key: String
    let category_id: Int
    let id: Int
    let link: String
    let name: String
    //let status: Int
    let created_date: Date
    var updated_date: Date
    
    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID

        guard
            let category_id   = document.get("id") as? Int,
            let id    = document.get("id") as? Int
            //let status  = document.get("status") as? Int
            else { throw ModelError.parseError }
        self.category_id    = category_id
        self.id             = id
        //self.status         = status
        self.created_date   = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()
        self.updated_date   = (document.get("updated_at") as? Timestamp)?.dateValue() ?? Date()
        self.link           = document.get("url") as? String ?? ""
        self.name           = (document.get("name") as? String) ?? ""
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.key == rhs.key &&
            lhs.name == rhs.name
    }
}


