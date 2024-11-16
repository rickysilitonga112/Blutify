//
//  HapticFeedbackManager.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import Foundation
import UIKit

final class HapticFeedbackManager {
  static let shared = HapticFeedbackManager()

  private init(){}

  public func vibrateForSelection() {
    DispatchQueue.main.async {
      let generator = UISelectionFeedbackGenerator()
      generator.prepare()
      generator.selectionChanged()
    }
  }

  public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
    DispatchQueue.main.async {
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(type)
    }
  }
}
