//
//  ObservableConvertibleType.swift
//  GooRanking
//
//  Created by cano on 2018/12/15.
//  Copyright © 2018 deskplate. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum Result<Response> {
    case succeeded(Response)
    case failed(Error)
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

