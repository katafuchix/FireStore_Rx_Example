//
//  ViewController.swift
//  FireStore_Rx_Example
//
//  Created by cano on 2023/01/26.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseFirestore

class ViewController: UIViewController {

    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        let (categories, error) = Driver<[Category]>.split(result:self.getData().resultDriver())
        categories.asObservable().subscribe(onNext: { categories in
            for category in categories {
                print(category)
                print(category.id)
                print(category.name)
            }
        }).disposed(by: rx.disposeBag)
        
        
        /*
        // subscribe で使う場合
        self.getData().subscribe(onNext: { categories in
            for category in categories {
                print(category)
                print(category.name)
            }
        }).disposed(by: rx.disposeBag)
        */
        
        /*
        // よくある方法
        database.collection("goo_ranking_category").getDocuments() { (querySnapshot, error) in
             if let error = error {
                 print("ドキュメントの取得に失敗しました:", error)
             } else {
                 print("ドキュメントの取得に成功しました")
                 for document in querySnapshot!.documents {
                     let data = document.data()
                     print(data)
                 }
            }
        }
        */
    }

    // FireStore のデータを取得するObserver処理
    func getData() -> Observable<[Category]> {
        return Observable.create { (observer: AnyObserver<[Category]>) -> Disposable in
            Firestore.firestore().collection("goo_ranking_category").getDocuments { (querySnapshot, error) in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let querySnapshot = querySnapshot, !querySnapshot.isEmpty else {
                    observer.onError( ModelError.parseError )
                    return
                }
                // DocumentSnapshottから変換して返す
                let categories = querySnapshot.documents.compactMap({ try? Category(from: $0) })
                                    .sorted(by: { $0.id < $1.id })
                observer.on(.next(categories))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

