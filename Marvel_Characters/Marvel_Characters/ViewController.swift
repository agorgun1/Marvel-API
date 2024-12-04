import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    private var collectionView: UICollectionView!
    private var searchBar = UISearchBar()
    private var sortingSegment: UISegmentedControl!
    private var toggleViewButton: UIButton!
    private var nextButton: UIButton!
    private var prevButton: UIButton!

    private var characters: [Character] = []
    private var isGridView = false 
    private var currentPage = 0
    private let itemsPerPageListView = 10
    private let itemsPerPageGridView = 20
    private var isFetchingData = false
    private var currentQuery: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        setupPaginationButtons()
        fetchCharacters()
    }

    private func setupNavigationBar() {
        title = "Characters"
    }

    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        view.addSubview(searchBar)

        sortingSegment = UISegmentedControl(items: ["Name ASC", "Name DESC"])
        sortingSegment.translatesAutoresizingMaskIntoConstraints = false
        sortingSegment.selectedSegmentIndex = 0
        sortingSegment.addTarget(self, action: #selector(sortingChanged), for: .valueChanged)
        view.addSubview(sortingSegment)

        toggleViewButton = UIButton(type: .system)
        toggleViewButton.setTitle("Grid View", for: .normal)
        toggleViewButton.translatesAutoresizingMaskIntoConstraints = false
        toggleViewButton.addTarget(self, action: #selector(toggleViewButtonTapped), for: .touchUpInside)
        view.addSubview(toggleViewButton)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),

            sortingSegment.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            sortingSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            sortingSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sortingSegment.heightAnchor.constraint(equalToConstant: 30),

            toggleViewButton.topAnchor.constraint(equalTo: sortingSegment.bottomAnchor, constant: 10),
            toggleViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleViewButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupCollectionView() {
        let layout = createListLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white

        collectionView.register(CharacterListCell.self, forCellWithReuseIdentifier: "CharacterListCell")
        collectionView.register(CharacterGridCell.self, forCellWithReuseIdentifier: "CharacterGridCell")
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: toggleViewButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }

    private func setupPaginationButtons() {
        prevButton = UIButton(type: .system)
        prevButton.setTitle("Previous", for: .normal)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        prevButton.isEnabled = false 

        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        view.addSubview(prevButton)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            prevButton.heightAnchor.constraint(equalToConstant: 40),

            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func fetchCharacters(searchQuery: String? = nil, isPagination: Bool = false) {
        guard !isFetchingData else { return }
        isFetchingData = true

        let itemsPerPage = isGridView ? itemsPerPageGridView : itemsPerPageListView
        let endpoint = MarvelAPI.charactersEndpoint(page: currentPage + 1, itemsPerPage: itemsPerPage, query: searchQuery)

        MarvelAPIService.shared.getCharacters(from: endpoint) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetchingData = false
                switch result {
                case .success(let newCharacters):
                    if isPagination {
                        self.characters.append(contentsOf: newCharacters)
                    } else {
                        self.characters = newCharacters
                    }
                    self.collectionView.reloadData()
                    self.updatePaginationButtons()
                case .failure(let error):
                    print("Error fetching characters: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func prevButtonTapped() {
        if currentPage > 0 {
            currentPage -= 1
            fetchCharacters(searchQuery: currentQuery, isPagination: false)
        }
    }

    @objc private func nextButtonTapped() {
        currentPage += 1
        fetchCharacters(searchQuery: currentQuery, isPagination: false)
    }

    private func updatePaginationButtons() {
        prevButton.isEnabled = currentPage > 0
        nextButton.isEnabled = characters.count >= (isGridView ? itemsPerPageGridView : itemsPerPageListView)
    }

    @objc private func toggleViewButtonTapped() {
        isGridView.toggle()
        let newLayout = isGridView ? createGridLayout() : createListLayout()
        collectionView.setCollectionViewLayout(newLayout, animated: true)
        toggleViewButton.setTitle(isGridView ? "List View" : "Grid View", for: .normal)
        collectionView.reloadData()
    }

    @objc private func sortingChanged() {
        switch sortingSegment.selectedSegmentIndex {
        case 0: characters.sort { $0.name < $1.name }
        case 1: characters.sort { $0.name > $1.name }
        default: break
        }
        collectionView.reloadData()
    }

    private func createListLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView?.frame.width ?? view.frame.width - 20, height: 120)
        layout.minimumLineSpacing = 10
        return layout
    }

    private func createGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = (collectionView?.frame.width ?? view.frame.width - 30) / 2
        layout.itemSize = CGSize(width: width - 10, height: width + 50)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }

        currentPage = 0
        currentQuery = query
        characters.removeAll()
        collectionView.reloadData()

        fetchCharacters(searchQuery: query, isPagination: false)
    }

    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }

    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character = characters[indexPath.item]

        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterGridCell", for: indexPath) as! CharacterGridCell
            cell.configure(with: character)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterListCell", for: indexPath) as! CharacterListCell
            let isFavorite = FavoritesManager.shared.isFavorite(characterID: character.id)
            cell.configure(with: character, isFavorite: isFavorite)
            return cell
        }
    }

    @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCharacter = characters[indexPath.item]
        performSegue(withIdentifier: "GoToSecond", sender: selectedCharacter)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToSecond",
           let destinationVC = segue.destination as? SecondPageViewController,
           let character = sender as? Character {
            destinationVC.character = character
        }
    }
}
