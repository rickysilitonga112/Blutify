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

  // stack control view
  private let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  private var loadingView: UIView?

  private let timerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "00:00 / 00:00"

    return label
  }()

  // MARK: - Action button
  private let playPauseButton = UIButton(type: .system)
  private let nextButton = UIButton(type: .system)
  private let prevButton = UIButton(type: .system)
  private let slider = UISlider()

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

    styleButton(playPauseButton, sfSymbolName: BFConstants.Button.play)
    styleButton(prevButton, sfSymbolName: BFConstants.Button.prev)
    styleButton(nextButton, sfSymbolName: BFConstants.Button.next)

    // Slider styling
    slider.minimumTrackTintColor = .appBlue
    slider.maximumTrackTintColor = .lightGray
    slider.thumbTintColor = .appBlue


    buttonStackView.addArrangedSubview(prevButton)
    buttonStackView.addArrangedSubview(playPauseButton)
    buttonStackView.addArrangedSubview(nextButton)

    playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

    addSubviews(searchBar, tableView, buttonStackView, slider, timerLabel)
  }

  private func setupConstraints() {
    playPauseButton.translatesAutoresizingMaskIntoConstraints = false
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
      tableView.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -20),

      buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      buttonStackView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),

      slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      slider.bottomAnchor.constraint(equalTo: timerLabel.topAnchor, constant: -20),

      timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      timerLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }


  // Common button styling
  private func styleButton(_ button: UIButton, sfSymbolName: String, tintColor: UIColor = .white, size: CGFloat = 44) {
    let config = UIImage.SymbolConfiguration(pointSize: size / 2, weight: .bold)
    if let image = UIImage(systemName: sfSymbolName, withConfiguration: config) {
      button.setImage(image, for: .normal)
    }
  }

  private func formatTime(seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let secondsRemaining = Int(seconds) % 60
    return String(format: "%02d:%02d", minutes, secondsRemaining)
  }

  // MARK: - Objc Helpers
  @objc private func playPauseTapped() {
    // configure haptic
    HapticFeedbackManager.shared.vibrateForSelection()

    let index = viewModel.currentTrackIndex < 0 ? 0 : viewModel.currentTrackIndex
    if viewModel.audioPlayer != nil {
      // Stop existing playback
      viewModel.stopMusic()
    } else {
      viewModel.startMusic(at: index)
    }
  }

  @objc private func nextTapped() {
    // configure haptic
    HapticFeedbackManager.shared.vibrateForSelection()

    viewModel.startMusic(at: min(viewModel.currentTrackIndex + 1, viewModel.tracks.count - 1))
  }

  @objc private func prevTapped() {
    // configure haptic
    HapticFeedbackManager.shared.vibrateForSelection()
    
    viewModel.startMusic(at:  max(viewModel.currentTrackIndex - 1, 0))
  }

  @objc private func sliderChanged() {
    guard let player = viewModel.audioPlayer else { return }
    let seconds = Double(slider.value)
    let time = CMTime(seconds: seconds, preferredTimescale: 600)
    player.seek(to: time)
  }
}

// MARK: - Search View Delegate
extension HomeView: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    performSearch(query: query)
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      viewModel.loadRecommendations()
    }
  }

  private func performSearch(query: String) {
    showLoadingView()
    viewModel.perfromSearch(query: query)
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
      let imageName = viewModel.isMusicPlaying ? BFConstants.Button.pauseCircle : BFConstants.Button.playCircle

      let playIcon = UIImageView(image: UIImage(systemName: imageName))
      playIcon.tintColor = .appBlue
      cell.accessoryView = playIcon
    } else {
      cell.accessoryType = .none
      cell.accessoryView = nil
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // configure haptic
    HapticFeedbackManager.shared.vibrateForSelection()
    
    viewModel.startMusic(at: indexPath.row)
    tableView.reloadData()
  }
}

// MARK: - Loading
extension HomeView {
  func showLoadingView() {
    guard self.loadingView == nil else { return }

    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .black
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])

    self.loadingView = activityIndicator
  }

  func hideLoadingView() {
    loadingView?.removeFromSuperview()
    loadingView = nil
  }
}

// MARK: - VM Delegate
extension HomeView: HomeViewModelDelegate {
  func didStartPlaying(track: Track) {
    // Preview duration (Spotify tracks are usually 30 seconds)
    slider.maximumValue = Float(viewModel.trackDuration)
    slider.value = 0.0

    // set the icon to pause
    styleButton(playPauseButton, sfSymbolName: BFConstants.Button.pause)
    tableView.reloadData()
  }

  func didStopPlaying() {
    // set the icon to play
    styleButton(playPauseButton, sfSymbolName: BFConstants.Button.play)
    tableView.reloadData()
  }

  func didFinishPlayingTrack() {
    // set the icon to pause
    styleButton(playPauseButton, sfSymbolName: BFConstants.Button.play)
    tableView.reloadData()
  }

  func updateTimer(time: CMTime) {
    let currentTime = CMTimeGetSeconds(time)
    slider.value = Float(currentTime)

    // update the label also
    let currentFormatted = formatTime(seconds: currentTime)
    let totalFormatted = formatTime(seconds: viewModel.trackDuration)
    timerLabel.text = "\(currentFormatted) / \(totalFormatted)"
  }

  func didErrorWith(message: String) {
    hideLoadingView()
    delegate?.didErrorWith(message: message)
  }

  func didFinishFetchingData() {
    tableView.reloadData()
    hideLoadingView()
  }

  func shouldShowError(message: String) {
    delegate?.didErrorWith(message: message)
  }

  func shouldShowLoading() {
    showLoadingView()
  }
}
