//
//  HomeViewModel.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import AVFoundation
import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    func didLoadInitialRecomendations()
    func shouldShowError(message: String)
    func shouldShowLoading()
}

final class HomeViewModel: NSObject {
    public weak var delegate: HomeViewModelDelegate?

    // MARK: - Properties
    var audioPlayer: AVPlayer?
    var playbackObserver: Any?
    var trackDuration: Double = 30.0

    var currentTrackIndex = 0
    var tracks: [Track] = []

    // MARK: - Helpers
    func loadRecommendations() {
        delegate?.shouldShowLoading()
        BFRequest.shared.fetchRecommendations { [weak self] tracks in
            DispatchQueue.main.async {
                if tracks.isEmpty {
                    self?.delegate?.shouldShowError(message: "No recommendations found.")
                } else {
                    let playableTracks = tracks.filter { $0.previewURL != nil }
                    self?.tracks = playableTracks
                    self?.delegate?.didLoadInitialRecomendations()
                }
            }
        }
    }
}
