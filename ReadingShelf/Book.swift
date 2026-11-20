import Foundation
import SwiftData

@Model
final class Book {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String
    var genre: String
    var status: String
    var rating: Int
    var notes: String
    var dateAdded: Date

    init(
        title: String,
        author: String,
        genre: String = "Other",
        status: String = "Want to read",
        rating: Int = 0,
        notes: String = "",
        dateAdded: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.genre = genre
        self.status = status
        self.rating = rating
        self.notes = notes
        self.dateAdded = dateAdded
    }
}