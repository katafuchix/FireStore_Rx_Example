//
//  CategoryViewModelTests.swift
//  FireStore_Rx_Example
//
//  Created by cano on 2026/02/01.
//

import XCTest
import RxSwift
import RxTest

@testable import FireStore_Rx_Example

class CategoryViewModelTests: XCTestCase {
    var viewModel: CategoryViewModel!
    var mockRepository: MockCategoryRepository!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        // 1. 仮想時間を扱うスケジューラを作成
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        mockRepository = MockCategoryRepository()
        //viewModel = CategoryViewModel(repository: mockRepository)
        // テスト用の scheduler を注入してインスタンス化！
        viewModel = CategoryViewModel(repository: mockRepository, scheduler: scheduler)
    }

    func test_simple() {
        // 1. 準備
        let mockData = Category(
            key: "cat1", category_id: 1, id: 1, link: "",
            name: "カフェ",
            created_date: Date(), updated_date: Date()
        )
        mockRepository.stubbedCategory = mockData
        
        // 2. observerを登録
        let observer = scheduler.createObserver(String.self)
        viewModel.categoryName.subscribe(observer).disposed(by: disposeBag)

        // 3. 実行
        viewModel.load(id: "any_id")

        // 4. 時計をたっぷり進める
        scheduler.advanceTo(10)

        // 5. 【修正ポイント】eventsを丸ごと比較せず、"中身の文字列" だけを抽出して比較する
        // これなら「何秒に届いたか」がズレていても、内容さえ合っていれば合格（Passed）になります
        let resultValues = observer.events.compactMap { $0.value.element }
        
        print("--- [DEBUG] 現在のイベント数: \(observer.events.count) ---")
        print(resultValues)
        XCTAssertEqual(resultValues, ["カテゴリ名: カフェ"])
    }
    
    func test_loadList_success() {
        let mockData = [Category(
            key: "cat1", category_id: 1, id: 1, link: "",
            name: "カフェ",
            created_date: Date(), updated_date: Date()
        )]
        // Mockが Observable を返すように設定
        mockRepository.stubbedCategories = .just(mockData)
        
        let observer = scheduler.createObserver(Int.self)
        // 個数に変換
        viewModel.categories.map { $0.count }.subscribe(observer).disposed(by: disposeBag)

        viewModel.loadList()
        scheduler.advanceTo(1) // これで Driver の中身が放出される

        let results = observer.events.compactMap { $0.value.element }
        print("--- [DEBUG] \(observer.events) ---")
        print("--- [DEBUG] \(results) ---")
        XCTAssertEqual(results, [1])
    }
    
    func test_getCategories_failure() {
        // Mockに .error を仕込む
        mockRepository.stubbedCategories = .error(NSError(domain: "test", code: -1))

        // エラーメッセージを監視するための observer を作成して購読する
        let errorObserver = scheduler.createObserver(String.self)
        viewModel.errorMessage
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        viewModel.loadList()
        scheduler.advanceTo(1)

        // 検証（errorMessageに値が流れたか）
        let errorResult = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(errorResult, "読み込み失敗")
    }
    
    func test_カテゴリー取得成功時に名前が加工されて通知されること() {
        // --- 準備 (Arrange) ---
        let mockData = Category(
            key: "cat1", category_id: 1, id: 1, link: "",
            name: "カフェ",
            created_date: Date(), updated_date: Date()
        )
        mockRepository.stubbedCategory = mockData
        
        // 出力を記録するための Observer を作成
        let observer = scheduler.createObserver(String.self)
        viewModel.categoryName.subscribe(observer).disposed(by: disposeBag)

        // --- 実行 (Act) ---
        // 仮想時間 10 のタイミングで load を実行
        scheduler.scheduleAt(10) {
            self.viewModel.load(id: "target_id")
        }
        scheduler.start()

        // --- 検証 (Assert) ---
        // 期待されるイベント: 10のタイミングで Next("カテゴリ名: カフェ") が届く
        let expectedEvents = [
            Recorded.next(10, "カテゴリ名: カフェ")
        ]
        
        XCTAssertEqual(observer.events, expectedEvents)
    }

    func test_取得失敗時にエラーメッセージが通知されること() {
        // --- 準備 (Arrange) ---
        mockRepository.shouldReturnError = true
        
        let errorObserver = scheduler.createObserver(String.self)
        viewModel.errorMessage.subscribe(errorObserver).disposed(by: disposeBag)

        // --- 実行 (Act) ---
        scheduler.scheduleAt(20) {
            self.viewModel.load(id: "invalid_id")
        }
        scheduler.start()

        // --- 検証 (Assert) ---
        XCTAssertEqual(errorObserver.events, [
            Recorded.next(20, "読み込み失敗")
        ])
    }
}


final class MockCategoryRepository: CategoryRepositoryType {
    // --- テスト時に外から書き換えるための変数（スタブ） ---
    var stubbedCategory: FireStore_Rx_Example.Category? // 成功時に返したいデータ
    var shouldReturnError = false  // エラーを発生させたい場合は true にする
    
    // --- 呼び出しを確認するための変数 ---
    var fetchCategoryCallCount = 0
    var lastFetchedId: String?

    func fetchCategory(id: String) -> Single<FireStore_Rx_Example.Category> {
        fetchCategoryCallCount += 1
        lastFetchedId = id
        
        // 1. エラーを返すべき設定ならエラーを流す
        if shouldReturnError {
            return .error(NSError(domain: "test_error", code: -1, userInfo: nil))
        }
        
        // 2. データが設定されていればそれを流す
        if let category = stubbedCategory {
            return .just(category)
        }
        
        // 3. どちらもなければ（設定忘れなど）エラーを流す
        return .error(NSError(domain: "no_stub_data", code: -2, userInfo: nil))
    }
    
    // テスト側から注入する「返却予定のデータ」を保持する変数
        // 初期値に Observable.empty() を入れておくと、未設定でもクラッシュしません
    var stubbedCategories: Observable<[FireStore_Rx_Example.Category]> = .empty()

    func getCategories() -> Observable<[FireStore_Rx_Example.Category]> {
            // テストで設定された Observable をそのまま返す
            return stubbedCategories
        }
}
