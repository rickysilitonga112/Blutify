//
//  SongTableViewCell.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import UIKit
import Kingfisher

class SongTableViewCell: UITableViewCell {
  static let cellIdentifier = "SongTableViewCell"

  private let albumImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 8
    imageView.clipsToBounds = true
    return imageView
  }()

  private let songLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    return label
  }()

  private let artistLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 13, weight: .regular)
    return label
  }()

  private let albumLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 13, weight: .light)
    return label
  }()

  private lazy var labelsStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [songLabel, artistLabel, albumLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubviews(albumImageView, labelsStackView)
    setupConstraints()
    accessoryType = .disclosureIndicator
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    albumImageView.image = nil
    songLabel.text = nil
    artistLabel.text = nil
    albumLabel.text = nil
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // Album ImageView constraints
      albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      albumImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      albumImageView.widthAnchor.constraint(equalToConstant: 60),
      albumImageView.heightAnchor.constraint(equalToConstant: 60),

      // Labels StackView constraints
      labelsStackView.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 16),
      labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

      // Ensure the album image and stack view fit within the cell
      albumImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
      labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8)
    ])
  }

  // Public method to configure the cell
  func configure(song: String, artist: String, album: String, imageURL: URL?) {
    songLabel.text = song
    artistLabel.text = artist
    albumLabel.text = album

    if let url = imageURL {
      albumImageView.kf.setImage(with: url)
    }
  }
}
