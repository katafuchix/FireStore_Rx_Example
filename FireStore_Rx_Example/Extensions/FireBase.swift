//
//  FireBase.swift
//  FireStore_Rx_Example
//
//  Created by cano on 2026/01/24.
//


import FirebaseFirestore
import RxSwift

// MARK: - DocumentReference
extension Reactive where Base: DocumentReference {
    /// ドキュメントのリアルタイム購読
    func listen() -> Observable<DocumentSnapshot> {
        return Observable.create { observer in
            let listener = self.base.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    observer.onNext(snapshot)
                }
            }
            return Disposables.create { listener.remove() }
        }
    }
    
    /// ドキュメントを一度だけ取得
    func getDocument() -> Single<DocumentSnapshot> {
        return Single.create { single in
            self.base.getDocument { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else if let snapshot = snapshot {
                    single(.success(snapshot))
                }
            }
            return Disposables.create()
        }
    }
    
    /// ドキュメントに書き込み
    func setData(_ data: [String: Any], merge: Bool = false) -> Completable {
        return Completable.create { completable in
            self.base.setData(data, merge: merge) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
}

// MARK: - CollectionReference
extension Reactive where Base: CollectionReference {
    /// コレクションのリアルタイム購読
    func listen() -> Observable<QuerySnapshot> {
        return Observable.create { observer in
            let listener = self.base.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    observer.onNext(snapshot)
                }
            }
            return Disposables.create { listener.remove() }
        }
    }
    
    /// コレクションの一度だけ取得
    func getDocuments() -> Single<QuerySnapshot> {
        return Single.create { single in
            self.base.getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else if let snapshot = snapshot {
                    single(.success(snapshot))
                }
            }
            return Disposables.create()
        }
    }
    
    /*
    /// コレクションの一度だけ取得 (Observable に変換)
    func getDocuments() -> Observable<QuerySnapshot> {
        return Observable.create { observer in
            self.base.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    observer.onNext(snapshot)
                    observer.onCompleted() // 一回で完了
                }
            }
            return Disposables.create()
        }
    }
    */
    /// ドキュメントを追加
    func addDocument(data: [String: Any]) -> Single<DocumentReference> {
        return Single.create { single in
            var ref: DocumentReference? = nil
            ref = self.base.addDocument(data: data) { error in
                if let error = error {
                    single(.failure(error))
                } else if let ref = ref {
                    single(.success(ref))
                }
            }
            return Disposables.create()
        }
    }
}

/*
// Query 用
extension Reactive where Base: Query {
    func getDocuments() -> Single<QuerySnapshot> {
        return Single.create { single in
            self.base.getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else if let snapshot = snapshot {
                    single(.success(snapshot))
                }
            }
            return Disposables.create()
        }
    }
}
*/
extension Reactive where Base: Query {
    /// Firestore の getDocuments を 1回だけ Observable で流す
    func getDocuments() -> Observable<QuerySnapshot> {
        return Observable.create { observer in
            self.base.getDocuments { snapshot, error in    // 元の Query インスタンスを self.base として参照
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot {
                    observer.onNext(snapshot)
                    observer.onCompleted()   // ここで終了するのがポイント
                }
            }
            return Disposables.create()
        }
    }
}

