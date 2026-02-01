//
//  CategoryRepository.swift
//  FireStore_Rx_Example
//
//  Created by cano on 2026/02/01.
//

import FirebaseFirestore
import RxSwift

protocol CategoryRepositoryType {
    // DocumentSnapshotをそのまま返さず、Category（モデル）を返す
    func fetchCategory(id: String) -> Single<Category>
    func getCategories() -> Observable<[Category]>
}

final class CategoryRepository: CategoryRepositoryType {
    private let db = Firestore.firestore()
    
    func fetchCategory(id: String) -> Single<Category> {
        // Rx拡張を使って取得し、その場でCategoryに変換する
        return db.collection("categories").document(id).rx.getDocument()
            .map { snapshot in
                try Category(from: snapshot) // ここで変換！
            }
    }
    
    func getCategories() -> Observable<[Category]> {
        return Firestore.firestore().collection("categories")
            .rx.getDocuments()
            .map { $0.documents }
            .map { documents in
                documents.compactMap { doc in try? Category(from: doc) }
            }
    }
}
