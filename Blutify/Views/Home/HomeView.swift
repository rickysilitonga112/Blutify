//
//  HomeView.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import AVFoundation
import Foundation
import UIKit


protocol HomeViewDelegate: AnyObject {
  func didErrorWith(message: String)
}

final class HomeView: UIView {
  private let viewModel = HomeViewModel()

  public weak var delegate: HomeViewDelegate?


  /// Search bar
  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.placeholder = "Search for music"
    return searchBar
  }()

  /// table view
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(
      SongTableViewCell.self,
      forCellReuseIdentifier: SongTableViewCell.cellIdentifier
    )
    return tableView
  }()

  // MARK: - Action button
  private let playButton = UIButton(type: .system)
  private let stopButton = UIButton(type: .system)
  private let nextButton = UIButton(type: .system)
  private let prevButton = UIButton(type: .system)
  private let slider = UISlider()

  private var loadingView: UIView?

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    // delegation
    viewModel.delegate = self

    setupViews()
    setupConstraints()

    // fetch initial recomendation
    viewModel.loadRecommendations()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Helpers
  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false
    
    searchBar.delegate = self
    tableView.delegate = self
    tableView.dataSource = self

    styleButton(playButton, sfSymbolName: "play")
    styleButton(stopButton, sfSymbolName: "pause")
    styleButton(prevButton, sfSymbolName: "backward.frame")
    styleButton(nextButton, sfSymbolName: "forward.frame")

    // Slider styling
    slider.minimumTrackTintColor = .appBlue
    slider.maximumTrackTintColor = .lightGray
    slider.thumbTintColor = .appBlue

    playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
    stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

    addSubviews(searchBar, tableView, playButton, stopButton, nextButton, prevButton, slider)
  }

  func setupConstraints() {
    playButton.translatesAutoresizingMaskIntoConstraints = false
    stopButton.translatesAutoresizingMaskIntoConstraints = false
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    prevButton.translatesAutoresizingMaskIntoConstraints = false
    slider.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),

      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -20),

      playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      playButton.bottomAnchor.constraint(equalTo: stopButton.topAnchor, constant: -10),

      stopButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      stopButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),

      nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      nextButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),

      prevButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      prevButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),

      slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      slider.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }

  func showLoadingView() {
    guard loadingView == nil else { return } // Prevent multiple overlays

    let overlay = UIView(frame: bounds)
    overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)

    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .white
    activityIndicator.startAnimating()

    overlay.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
    ])

    addSubview(overlay)
    loadingView = overlay
  }

  func hideLoadingView() {
    loadingView?.removeFromSuperview()
    loadingView = nil
  }

  // Common button styling
  func styleButton(_ button: UIButton, sfSymbolName: String, tintColor: UIColor = .white, size: CGFloat = 44) {
      let config = UIImage.SymbolConfiguration(pointSize: size / 2, weight: .bold)
      if let image = UIImage(systemName: sfSymbolName, withConfiguration: config) {
          button.setImage(image, for: .normal)
      }
  }


  @objc private func playTapped() {
    guard viewModel.tracks.indices.contains(viewModel.currentTrackIndex),
          let url = viewModel.tracks[viewModel.currentTrackIndex].previewURL else {
      return
    }

    // Stop existing playback
    stopMusic()

    startMusic(with: url)
  }

  @objc private func stopTapped() {
      stopMusic()
  }

  @objc private func nextTapped() {
    viewModel.currentTrackIndex = min(viewModel.currentTrackIndex + 1, viewModel.tracks.count - 1)
    playTapped()
    tableView.reloadData()
  }

  @objc private func prevTapped() {
    viewModel.currentTrackIndex = max(viewModel.currentTrackIndex - 1, 0)
    playTapped()
    tableView.reloadData()
  }

  func startMusic(with url: URL) {
    viewModel.audioPlayer = AVPlayer(url: url)
    viewModel.audioPlayer?.play()

    // Preview duration (Spotify tracks are usually 30 seconds)
    viewModel.trackDuration = 30.0
    slider.maximumValue = Float(viewModel.trackDuration)
    slider.value = 0.0

    addPlaybackObserver()

    // update play icon
    tableView.reloadData()
  }

  func stopMusic() {
    viewModel.audioPlayer?.pause()
    viewModel.audioPlayer = nil

    if let observer = viewModel.playbackObserver {
      NotificationCenter.default.removeObserver(observer)
      viewModel.playbackObserver = nil
    }
  }

  @objc private func sliderChanged() {
    guard let player = viewModel.audioPlayer else { return }
    let seconds = Double(slider.value)
    let time = CMTime(seconds: seconds, preferredTimescale: 600)
    player.seek(to: time)
  }

  private func addPlaybackObserver() {
    viewModel.playbackObserver = viewModel.audioPlayer?.addPeriodicTimeObserver(
      forInterval: CMTime(seconds: 1, preferredTimescale: 600),
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }
      let currentTime = CMTimeGetSeconds(time)
      self.slider.value = Float(currentTime)
    }
  }
}


// MARK: - Search View Delegate
extension HomeView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    performSearch(query: query)
  }

  private func performSearch(query: String) {
//    showLoadingView()
    BFRequest.shared.searchMusic(query: query) { [weak self] tracks in
      DispatchQueue.main.async {
//        self?.hideLoadingView()
        if tracks.isEmpty {
//          self?.showAPIError(message: "No results found for \"\(query)\".")
        } else {
          self?.viewModel.tracks = tracks
          self?.tableView.reloadData()
        }
      }
    }
  }

}

// MARK: - Table View Delegate and Data source
extension HomeView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.tracks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: SongTableViewCell.cellIdentifier,
      for: indexPath
    ) as? SongTableViewCell else {
      fatalError("Failed to dequeue SongTableViewCell")
    }

    let track = viewModel.tracks[indexPath.row]

    let imageUrl = URL(string: track.album?.images?.last?.url ?? "")

    // Configure the cell's content
    cell.configure(
      song: track.name ?? "",
      artist: track.artists?.first?.name ?? "",
      album: track.album?.name ?? "",
      imageURL: imageUrl
    )

    // Set the accessory view for the currently selected song
    if indexPath.row == viewModel.currentTrackIndex {
      let playIcon = UIImageView(image: UIImage(systemName: "play.circle.fill"))
      playIcon.tintColor = .appBlue
      cell.accessoryView = playIcon
    } else {
      cell.accessoryType = .none
      cell.accessoryView = nil // Reset accessoryView for non-selected cells
    }

    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.currentTrackIndex = indexPath.row
    playTapped()
    tableView.reloadData() // Refresh to update play icon
  }
}


extension HomeView: HomeViewModelDelegate {
  func didLoadInitialRecomendations() {
    print("%% - Reloading table view")
    tableView.reloadData()
  }
  
  func shouldShowError(message: String) {
    // show error
    print("%% - Show error with message \(message)")
  }
}
