struct Character: Codable {
    let id: Int
    let name: String
    let series: SeriesInfo
    let thumbnail: Thumbnail
    let comics: ResourceInfo
    let events: ResourceInfo
    let stories: ResourceInfo

    var seriesCount: Int {
        return series.available
    }

    var imageURL: String {
        return "\(thumbnail.path).\(thumbnail.extension)".replacingOccurrences(of: "http://", with: "https://")
    }

    struct SeriesInfo: Codable {
        let available: Int
    }

    struct ResourceInfo: Codable {
        let available: Int
        let items: [ResourceItem]
    }

    struct ResourceItem: Codable {
        let name: String
    }

    struct Thumbnail: Codable {
        let path: String
        let `extension`: String
    }
}
