//
//  Reactive+UIViewController.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var dismissSelfFromPresentingViewControllerAnimated: Binder<Void> {
        return Binder(self.base) { viewController, _ in
            viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    var presentModalViewControllerAnimated: Binder<UIViewController> {
        return Binder(self.base) { presenting, presented in
            let presentor = presenting.navigationController ?? presenting
            presented.isModalInPresentation = true
            presentor.present(presented, animated: true, completion: nil)
        }
    }
}
