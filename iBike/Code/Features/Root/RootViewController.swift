//
//  RootViewController.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RootViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = RootViewModel()
    private let disposeBag = DisposeBag()
    private var root: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupBindings()
    }

    // MARK: - Layout

    fileprivate func removeCurrentChild() {
        guard
            let child = root,
            child.parent is RootViewController
            else { return }

        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    fileprivate func add(child: UIViewController) {
        guard child.parent == nil else { return }

        removeCurrentChild()

        addChild(child)
        view.addSubview(child.view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        child.didMove(toParent: self)

        root = child
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.output.newChildViewControllerRequiredSignal
            .emit(to: rx.root)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: RootViewController {
    var root: Binder<UIViewController> {
        return Binder(base) { parent, child in
            parent.add(child: child)
        }
    }
}
