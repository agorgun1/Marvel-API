import UIKit

class SecondPageViewController: UIViewController {
    var character: Character?

    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let seriesLabel = UILabel()
    private let comicsLabel = UILabel()
    private let eventsLabel = UILabel()
    private let storiesLabel = UILabel()
    private let heartButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        displayCharacterDetails()
        setupHeartButton()
    }

    private func setupHeartButton() {
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        let isFavorite = FavoritesManager.shared.isFavorite(characterID: character?.id ?? -1)
        updateHeartIcon(isFavorite: isFavorite)

        heartButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        view.addSubview(heartButton)

        NSLayoutConstraint.activate([
            heartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            heartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func updateHeartIcon(isFavorite: Bool) {
        let heartImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        heartButton.setImage(heartImage, for: .normal)
        heartButton.tintColor = isFavorite ? .red : .gray
    }

    @objc private func toggleFavorite() {
        guard let characterID = character?.id else { return }
        let isFavorite = FavoritesManager.shared.toggleFavorite(characterID: characterID)
        updateHeartIcon(isFavorite: isFavorite)
    }

    private func setupViews() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.contentMode = .scaleAspectFit
        view.addSubview(characterImageView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(nameLabel)

        seriesLabel.translatesAutoresizingMaskIntoConstraints = false
        seriesLabel.numberOfLines = 0
        view.addSubview(seriesLabel)

        comicsLabel.translatesAutoresizingMaskIntoConstraints = false
        comicsLabel.numberOfLines = 0
        view.addSubview(comicsLabel)

        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.numberOfLines = 0
        view.addSubview(eventsLabel)

        storiesLabel.translatesAutoresizingMaskIntoConstraints = false
        storiesLabel.numberOfLines = 0
        view.addSubview(storiesLabel)

        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            characterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 200),
            characterImageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            seriesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            seriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            seriesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            comicsLabel.topAnchor.constraint(equalTo: seriesLabel.bottomAnchor, constant: 20),
            comicsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            comicsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            eventsLabel.topAnchor.constraint(equalTo: comicsLabel.bottomAnchor, constant: 20),
            eventsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            storiesLabel.topAnchor.constraint(equalTo: eventsLabel.bottomAnchor, constant: 20),
            storiesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            storiesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            storiesLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func displayCharacterDetails() {
        guard let character = character else { return }

        nameLabel.text = character.name
        seriesLabel.text = "Series: \(character.seriesCount)"
        comicsLabel.text = "Comics:\n" + character.comics.items.map { $0.name }.joined(separator: "\n")
        eventsLabel.text = "Events:\n" + character.events.items.map { $0.name }.joined(separator: "\n")
        storiesLabel.text = "Stories:\n" + character.stories.items.map { $0.name }.joined(separator: "\n")

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
