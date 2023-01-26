//
//  CategoryListItem.swift
//  GooRanking
//
//  Created by cano on 2018/12/15.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class CategoryListItem {

    let key: String
    //let category_id: Int
    //let category_list_id: Int
    let ranking_id: Int
    let id: Int
    let item: String
    let summary: String
    let rank: Int
    //let created_date: Date
    //var updated_date: Date

    init(from document: DocumentSnapshot) throws {
        self.key = document.documentID

        guard
            let ranking_id        = document.get("ranking_id") as? Int,
            //let category_id        = document.get("category_id") as? Int,
            //let category_list_id   = document.get("category_list_id") as? Int,
            let id                 = document.get("id") as? Int,
            let rank_order         = document.get("rank_order") as? Int
            else { throw ModelError.parseError }

        //self.category_id        = category_id
        //self.category_list_id   = category_list_id
        self.id                 = id
        self.ranking_id         = ranking_id 
        //self.created_date       = (document.get("created_at") as? Timestamp)?.dateValue() ?? Date()//
        //self.updated_date       = (document.get("updated_at") as? Timestamp)?.dateValue() ?? Date()
        self.item               = document.get("name") as? String ?? ""
        self.summary            = document.get("summary") as? String ?? ""
        self.rank               = rank_order
    }
}

extension CategoryListItem: Equatable {
    static func == (lhs: CategoryListItem, rhs: CategoryListItem) -> Bool {
        return lhs.key == rhs.key &&
            lhs.item == rhs.item
    }
}
