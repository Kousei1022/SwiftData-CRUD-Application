import SwiftData
import SwiftUI

private enum ShelfFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case reading = "Reading"
    case finished = "Finished"

    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]
    @State private var searchText = ""
    @State private var selectedFilter: ShelfFilter = .all
    @State private var showingEditor = false

    private let ink = Color(red: 0.13, green: 0.22, blue: 0.19)
    private let paper = Color(red: 0.97, green: 0.96, blue: 0.92)

    private var visibleBooks: [Book] {
        books.filter { book in
            let matchesSearch = searchText.isEmpty
                || book.title.localizedCaseInsensitiveContains(searchText)
                || book.author.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == .all
                || (selectedFilter == .reading && book.status == "Reading")
                || (selectedFilter == .finished && book.status == "Finished")
            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    searchField
                    filterPicker
                    bookList
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
            .background(paper.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingEditor) {
                BookEditorView()
            }
        }
        .tint(ink)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("YOUR PERSONAL LIBRARY")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(1.7)
                        .foregroundStyle(ink.opacity(0.58))
                    Text("Reading\nShelf")
                        .font(.system(size: 42, weight: .regular, design: .serif))
                        .lineSpacing(-4)
                        .foregroundStyle(ink)
                        .accessibilityIdentifier("shelfHeading")
                }
                Spacer()
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(ink, in: Circle())
                }
                .accessibilityLabel("Add book")
                .accessibilityIdentifier("addBookButton")
            }

            HStack(spacing: 0) {
                metric(value: "\(books.count)", label: books.count == 1 ? "BOOK" : "BOOKS")
                Rectangle().fill(ink.opacity(0.15)).frame(width: 1, height: 34)
                metric(value: "\(books.filter { $0.status == "Finished" }.count)", label: "FINISHED")
                Rectangle().fill(ink.opacity(0.15)).frame(width: 1, height: 34)
                metric(value: "\(books.filter { $0.status == "Reading" }.count)", label: "IN PROGRESS")
            }
            .padding(.vertical, 13)
            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 4))
        }
    }

    private func metric(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 20, weight: .medium, design: .serif)).foregroundStyle(ink)
            Text(label).font(.system(size: 9, weight: .semibold)).tracking(0.8).foregroundStyle(ink.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(ink.opacity(0.55))
            TextField("Search title or author", text: $searchText)
                .font(.system(size: 15))
                .accessibilityIdentifier("bookSearchField")
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(ink.opacity(0.12), lineWidth: 1))
    }

    private var filterPicker: some View {
        Picker("Filter books", selection: $selectedFilter) {
            ForEach(ShelfFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("bookFilterPicker")
    }

    @ViewBuilder
    private var bookList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(selectedFilter == .all ? "On your shelf" : selectedFilter.rawValue)
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(ink)
                Spacer()
                Text("\(visibleBooks.count) TITLES")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(ink.opacity(0.48))
            }

            if visibleBooks.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(visibleBooks) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            BookRow(book: book)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("book-row-\(book.title)")
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                modelContext.delete(book)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .accessibilityIdentifier("delete-book-\(book.title)")
                        }
                        Rectangle().fill(ink.opacity(0.1)).frame(height: 1)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: searchText.isEmpty ? "books.vertical" : "magnifyingglass")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(ink.opacity(0.5))
            Text(searchText.isEmpty ? "A shelf with room to grow" : "No matching books")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(ink)
                .accessibilityIdentifier("emptyShelfMessage")
            Text(searchText.isEmpty ? "Add your first title to get started." : "Try another title or author.")
                .font(.system(size: 13))
                .foregroundStyle(ink.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 38)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
    }
}

private struct BookRow: View {
    let book: Book
    private let ink = Color(red: 0.13, green: 0.22, blue: 0.19)

    private var coverColor: Color {
        switch book.genre {
        case "Fiction": Color(red: 0.65, green: 0.32, blue: 0.23)
        case "History": Color(red: 0.29, green: 0.42, blue: 0.39)
        case "Science": Color(red: 0.76, green: 0.61, blue: 0.34)
        default: Color(red: 0.43, green: 0.46, blue: 0.34)
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(coverColor)
                Rectangle().fill(.white.opacity(0.22)).frame(width: 1).offset(x: -18)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(width: 54, height: 72)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundStyle(ink)
                    .lineLimit(2)
                Text(book.author)
                    .font(.system(size: 13))
                    .foregroundStyle(ink.opacity(0.62))
                    .lineLimit(1)
                Text(book.status.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(0.9)
                    .foregroundStyle(ink.opacity(0.56))
                    .padding(.top, 2)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ink.opacity(0.3))
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}