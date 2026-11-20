import SwiftUI

struct BookEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let book: Book?
    @State private var title: String
    @State private var author: String
    @State private var genre: String
    @State private var status: String
    @State private var rating: Int
    @State private var notes: String
    @FocusState private var titleFieldFocused: Bool

    private let genres = ["Fiction", "History", "Science", "Biography", "Other"]
    private let statuses = ["Want to read", "Reading", "Finished"]
    private let ink = Color(red: 0.13, green: 0.22, blue: 0.19)

    init(book: Book? = nil) {
        self.book = book
        _title = State(initialValue: book?.title ?? "")
        _author = State(initialValue: book?.author ?? "")
        _genre = State(initialValue: book?.genre ?? "Fiction")
        _status = State(initialValue: book?.status ?? "Want to read")
        _rating = State(initialValue: book?.rating ?? 0)
        _notes = State(initialValue: book?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("THE BOOK") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("bookTitleField")
                        .focused($titleFieldFocused)
                    TextField("Author", text: $author)
                        .accessibilityIdentifier("bookAuthorField")
                    Picker("Genre", selection: $genre) {
                        ForEach(genres, id: \.self) { Text($0) }
                    }
                }

                Section("YOUR READING") {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { Text($0) }
                    }
                    HStack {
                        Text("Rating")
                        Spacer()
                        StarRating(rating: $rating)
                    }
                    .accessibilityIdentifier("bookRatingControl")
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.97, green: 0.96, blue: 0.92))
            .navigationTitle(book == nil ? "New book" : "Edit book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  || author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("saveBookButton")
                }
            }
        }
        .tint(ink)
        .task {
            if book == nil {
                titleFieldFocused = true
            }
        }
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        if let book {
            book.title = cleanTitle
            book.author = cleanAuthor
            book.genre = genre
            book.status = status
            book.rating = rating
            book.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            modelContext.insert(Book(
                title: cleanTitle,
                author: cleanAuthor,
                genre: genre,
                status: status,
                rating: rating,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }
        dismiss()
    }
}

struct StarRating: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    rating = rating == value ? 0 : value
                } label: {
                    Image(systemName: value <= rating ? "star.fill" : "star")
                        .font(.system(size: 17))
                        .foregroundStyle(value <= rating ? Color(red: 0.76, green: 0.52, blue: 0.23) : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(value) star\(value == 1 ? "" : "s")")
            }
        }
    }
}