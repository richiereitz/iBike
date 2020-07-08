//
//  PublishRelay+Convenience.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension PublishRelay {
    func asAnyObserver() -> AnyObserver<Element> {
        return AnyObserver { event in
            guard let element = event.element else { return }
            self.accept(element)
        }
    }
}
