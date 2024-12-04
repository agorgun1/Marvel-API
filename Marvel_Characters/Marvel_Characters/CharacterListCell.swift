import UIKit

class CharacterListCell: UICollectionViewCell {
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let seriesCountLabel = UILabel()
    private let heartImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        seriesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        heartImageView.translatesAutoresizingMaskIntoConstraints = false

        heartImageView.contentMode = .scaleAspectFit
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(seriesCountLabel)
        contentView.addSubview(heartImageView)

        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 80),
            characterImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            seriesCountLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            seriesCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),

            heartImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            heartImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            heartImageView.widthAnchor.constraint(equalToConstant: 24),
            heartImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with character: Character, isFavorite: Bool) {
        nameLabel.text = character.name
        seriesCountLabel.text = "Series: \(character.seriesCount)"
        heartImageView.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        heartImageView.tintColor = isFavorite ? .red : .gray

        if let url = URL(string: character.imageURL) {
            fetchImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.characterImageView.image = image
                }
            }
        }
    }

    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}
