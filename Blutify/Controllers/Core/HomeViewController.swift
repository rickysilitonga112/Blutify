//
//  ViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 15/11/24.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
  private let spotifyAPI = SpotifyAPI()
  private var tracks: [Track] = []
  private var audioPlayer: AVPlayer?
  private var currentTrackIndex = 0
  private var playbackObserver: Any?
  private var trackDuration: Double = 30.0 // Default duration for Spotify previews
  private var loadingView: UIView?

  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search for music"
    return searchBar
  }()

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    return tableView
  }()

  private let playButton = UIButton(type: .system)
  private let stopButton = UIButton(type: .system)
  private let nextButton = UIButton(type: .system)
  private let prevButton = UIButton(type: .system)
  private let slider = UISlider()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    setupViews()
    setupConstraints()

    spotifyAPI.authenticate { success in
      if success {
        print("Authenticated successfully!")
        self.loadRecommendations()
      } else {
        print("Failed to authenticate.")
      }
    }
  }

  private func hideLoadingView() {
    loadingView?.removeFromSuperview()
    loadingView = nil
  }

  func showLoadingView() {
    let overlay = UIView(frame: view.bounds)
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

    view.addSubview(overlay)
    loadingView = overlay
  }

  private func setupViews() {
    searchBar.delegate = self
    tableView.delegate = self
    tableView.dataSource = self

    styleButton(playButton, title: "Play")
    styleButton(stopButton, title: "Stop")
    styleButton(nextButton, title: "Next")
    styleButton(prevButton, title: "Prev")

    // Slider styling
    slider.minimumTrackTintColor = .appBlue
    slider.maximumTrackTintColor = .lightGray
    slider.thumbTintColor = .appBlue

    playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
    stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

    view.addSubview(searchBar)
    view.addSubview(tableView)
    view.addSubview(playButton)
    view.addSubview(stopButton)
    view.addSubview(nextButton)
    view.addSubview(prevButton)
    view.addSubview(slider)
  }

  // Common button styling
  func styleButton(_ button: UIButton, title: String) {
    button.setTitle(title, for: .normal)
    button.backgroundColor = .appBlue
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.layer.cornerRadius = 25 // Rounded corners
    button.clipsToBounds = true
  }

  private func loadRecommendations() {
    DispatchQueue.main.async { [weak self] in
      self?.showLoadingView()
    }

    spotifyAPI.fetchRecommendations { [weak self] tracks in
      DispatchQueue.main.async {
        self?.hideLoadingView()
        if tracks.isEmpty {
          self?.showAPIError(message: "No recommendations found.")
        } else {
          self?.tracks = tracks
          self?.tableView.reloadData()
        }
      }
    }
  }


  private func showAPIError(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  private func setupConstraints() {
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    playButton.translatesAutoresizingMaskIntoConstraints = false
    stopButton.translatesAutoresizingMaskIntoConstraints = false
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    prevButton.translatesAutoresizingMaskIntoConstraints = false
    slider.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -20),

      playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playButton.bottomAnchor.constraint(equalTo: stopButton.topAnchor, constant: -10),

      stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stopButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),

      nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      nextButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),

      prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      prevButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -20),

      slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      slider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }

  @objc private func playTapped() {
    guard tracks.indices.contains(currentTrackIndex),
          let url = tracks[currentTrackIndex].previewURL else { return }

    // Stop existing playback
    stopTapped()

    audioPlayer = AVPlayer(url: url)
    audioPlayer?.play()

    trackDuration = 30.0 // Preview duration (Spotify tracks are usually 30 seconds)
    slider.maximumValue = Float(trackDuration)
    slider.value = 0.0

    addPlaybackObserver()
    tableView.reloadData() // Update play icon
  }


  @objc private func stopTapped() {
    audioPlayer?.pause()
    audioPlayer = nil

    if let observer = playbackObserver {
      NotificationCenter.default.removeObserver(observer)
      playbackObserver = nil
    }
  }

  @objc private func nextTapped() {
    currentTrackIndex = min(currentTrackIndex + 1, tracks.count - 1)
    playTapped()
    tableView.reloadData()
  }

  @objc private func prevTapped() {
    currentTrackIndex = max(currentTrackIndex - 1, 0)
    playTapped()
    tableView.reloadData()
  }


  @objc private func sliderChanged() {
    guard let player = audioPlayer else { return }
    let seconds = Double(slider.value)
    let time = CMTime(seconds: seconds, preferredTimescale: 600)
    player.seek(to: time)
  }

  private func addPlaybackObserver() {
    playbackObserver = audioPlayer?.addPeriodicTimeObserver(
      forInterval: CMTime(seconds: 1, preferredTimescale: 600),
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }
      let currentTime = CMTimeGetSeconds(time)
      self.slider.value = Float(currentTime)
    }
  }
}

extension HomeViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    performSearch(query: query)
  }

  private func performSearch(query: String) {
    showLoadingView()
    spotifyAPI.searchMusic(query: query) { [weak self] tracks in
      DispatchQueue.main.async {
        self?.hideLoadingView()
        if tracks.isEmpty {
          self?.showAPIError(message: "No results found for \"\(query)\".")
        } else {
          self?.tracks = tracks
          self?.tableView.reloadData()
        }
      }
    }
  }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let track = tracks[indexPath.row]
    cell.textLabel?.text = "\(track.name) - \(track.artist)"

    // Add play icon if this is the currently playing song
    if indexPath.row == currentTrackIndex {
      let playIcon = UIImageView(image: UIImage(systemName: "play.circle.fill"))
      playIcon.tintColor = .systemBlue
      cell.accessoryView = playIcon
    } else {
      cell.accessoryView = nil
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    currentTrackIndex = indexPath.row
    playTapped()
    tableView.reloadData() // Refresh to update play icon
  }
}
