# FireStore_Rx_Example

- RxFirebase の ビルドが M1 mac 以上で面倒なので代わりの処理を考案中
- extension を作成して結果とエラーを一度で取得できるように
- Podsも含めて M2 mac で Build Settings に変更を加えずにビルドできることを確認

```
let (objects, error) = Driver<[Model]>.split(result: Observable処理.resultDriver())

```

- 上記コード

```
extension SharedSequence {

    /// split result to Element and Error
    ///
    /// - Parameter result: Driver<Result<Element>>
    /// - Returns: Driver<E>, Driver<Error>
    static func split(result: Driver<Result<Element>>) -> (response: Driver<Element>, error: Driver<Error>) {
        let responseDriver = result.flatMap { result -> Driver<Element> in
            switch result {
            case .succeeded(let response):
                return Driver.just(response)
            case .failed:
                return Driver.empty()
            } }
        let errorDriver = result.flatMap { result -> Driver<Error> in
            switch result {
            case .succeeded:
                return Driver.empty()
            case .failed(let error):
                return Driver.just(error)
            } }
        return (responseDriver, errorDriver)
    }
}

extension ObservableConvertibleType {

    func resultDriver() -> Driver<Result<Element>> {
        return self.asObservable()
            .map { Result.succeeded($0) }
            .asDriver { Driver.just(Result.failed($0)) }
    }
    

    func materializeAsDriver() -> Driver<Event<Element>> {
        return self.asObservable()
            .materialize()
            .asDriver(onErrorDriveWith: .empty())
    }
}
```
