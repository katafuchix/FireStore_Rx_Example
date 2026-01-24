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

        // よくある例
        let (categories, error) = Driver<[Category]>.split(result:self.getData().resultDriver())
        
        categories.asObservable().subscribe(onNext: { categories in
            for category in categories {
                print(category)
                print(category.id)
                print(category.name)
            }
        }).disposed(by: rx.disposeBag)
        
        error.asDriver().drive(onNext: { error in
            print(error)
        }).disposed(by: rx.disposeBag)
        
        
        // cf. https://qiita.com/katafuchix/items/e8814c89597137f68e5c
        // FireStoreから最新データを取得
        let (list, err) = Driver.split(result: self.getCategories().resultDriver())

        list.asDriver().drive(onNext: { items in
            for item in items {
                print(item)
                print(item.id)
                print(item.name)
            }
        }).disposed(by: rx.disposeBag)
        
        
        err.asDriver().drive(onNext: { error in
        print(error)
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
    
    // FireStore のデータを取得するObserver処理
    // cf. https://qiita.com/katafuchix/items/e8814c89597137f68e5c
    func getCategories() -> Observable<[Category]> {
        return Firestore.firestore().collection("goo_ranking_category")
            .rx.getDocuments()                  // QuerySnapshot
            .map { $0.documents }               // [QueryDocumentSnapshot]
            .map { $0.compactMap{ doc in return try? Category.init(from: doc) } }
    }
}

