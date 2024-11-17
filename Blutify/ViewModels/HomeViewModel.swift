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
  func didFinishFetchingData()
  func didErrorWith(message: String)
  func shouldShowError(message: String)
  func shouldShowLoading()
  func updateSliderValue(with newValue: Float)
  
  // player
  func didStartPlaying(track: Track)
  func didStopPlaying()
  func didFinishPlayingTrack()
}

final class HomeViewModel: NSObject {
  public weak var delegate: HomeViewModelDelegate?
  
  // MARK: - Properties
  var audioPlayer: AVPlayer?
  var playbackObserver: Any?
  var trackDuration: Double = 30.0
  
  var currentTrackIndex = -1
  var tracks: [Track] = []
  var isMusicPlaying: Bool = false
  
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
          self?.delegate?.didFinishFetchingData()
        }
      }
    }
  }
  
  func perfromSearch(query: String) {
    BFRequest.shared.searchMusic(query: query) { [weak self] tracks in
      DispatchQueue.main.async {
        self?.delegate?.shouldShowLoading()
        let playableSongs = tracks.filter { $0.previewURL != nil }
        if playableSongs.isEmpty {
          print("%% - Tracks is empty")
          self?.delegate?.didErrorWith(message: "No results found for \"\(query)\".")
        } else {
          self?.tracks = playableSongs
          self?.delegate?.didFinishFetchingData()
        }
      }
    }
  }
  
  // MARK: - Playback
  func startMusic(at index: Int) {
    guard tracks.indices.contains(index), let url = URL(string: tracks[index].previewURL ?? "") else { return }
    
    // Stop existing playback
    stopMusic()
    
    currentTrackIndex = index
    audioPlayer = AVPlayer(url: url)
    audioPlayer?.play()
    isMusicPlaying = true
    
    delegate?.didStartPlaying(track: tracks[index])
    
    addPlaybackObserver()
    
    // Add playback completion observer
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(musicDidFinishPlaying),
      name: .AVPlayerItemDidPlayToEndTime,
      object: audioPlayer?.currentItem
    )
  }
  
  func stopMusic() {
    audioPlayer?.pause()
    audioPlayer = nil
    isMusicPlaying = false
    
    // Remove playback observer
    if let observer = playbackObserver {
      NotificationCenter.default.removeObserver(observer)
      playbackObserver = nil
    }
    
    // Notify delegate to update UI
    delegate?.didStopPlaying()
    
    // Remove end-of-playback observer
    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
  }
  
  func addPlaybackObserver() {
    playbackObserver = audioPlayer?.addPeriodicTimeObserver(
      forInterval: CMTime(seconds: 1, preferredTimescale: 600),
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }
      let currentTime = CMTimeGetSeconds(time)
      delegate?.updateSliderValue(with: Float(currentTime))
    }
  }
}

extension HomeViewModel {
  // MARK: - Objc Helpers
  @objc private func musicDidFinishPlaying() {
    isMusicPlaying = false
    
    // Notify delegate about completion
    delegate?.didFinishPlayingTrack()
  }
}
