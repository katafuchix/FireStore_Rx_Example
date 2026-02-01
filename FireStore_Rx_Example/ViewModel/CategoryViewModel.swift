//
//  CategoryViewModel.swift
//  FireStore_Rx_Example
//
//  Created by cano on 2026/02/01.
//

import RxSwift
import RxCocoa

final class CategoryViewModel {
    private let repository: CategoryRepositoryType
    private let disposeBag = DisposeBag()
    private let scheduler: SchedulerType // スケジューラを保持
    
    // 出力（Viewが購読するもの）
    let categoryName = PublishSubject<String>()
    let errorMessage = PublishSubject<String>()
    let categories = PublishSubject<[Category]>()
    
    // 初期値に MainScheduler.instance を入れることで、既存コードへの影響を最小限にする
    init(repository: CategoryRepositoryType, scheduler: SchedulerType = MainScheduler.instance) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    func load(id: String) {
        repository.fetchCategory(id: id)
            .subscribe(onSuccess: { [weak self] category in
                self?.categoryName.onNext("カテゴリ名: \(category.name)")
            }, onFailure: { [weak self] error in
                self?.errorMessage.onNext("読み込み失敗")
            })
            .disposed(by: disposeBag)
    }
    
    func loadList() {
        let (list, err) = Driver<[Category]>
            .split(result:repository.getCategories()
            .observe(on: scheduler)
            .resultDriver())
            
            list.drive(categories)
                .disposed(by: disposeBag)
                
            err.map { _ in "読み込み失敗" }
                .drive(errorMessage)
                .disposed(by: disposeBag)
        }
}
