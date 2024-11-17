//
//  HomeViewModel.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {

}

final class HomeViewModel: NSObject {
    public weak var delegate: HomeViewModelDelegate?

    init(delegate: HomeViewModelDelegate? = nil) {
        self.delegate = delegate
    }
}
