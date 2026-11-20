import SwiftData
import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false

    let book: Book
    private let ink = Color(red: 0.13, green: 0.22, blue: 0.19)
    private let paper = Color(red: 0.97, green: 0.96, blue: 0.92)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.29, green: 0.42, blue: 0.39))
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.white.opacity(0.88))
                }
                .frame(height: 210)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    Text(book.genre.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(ink.opacity(0.55))
                    Text(book.title)
                        .font(.system(size: 34, weight: .regular, design: .serif))
                        .foregroundStyle(ink)
                        .accessibilityIdentifier("detailBookTitle")
                    Text("by \(book.author)")
                        .font(.system(size: 16))
                        .foregroundStyle(ink.opacity(0.67))
                }

                HStack {
                    Label(book.status, systemImage: "bookmark")
                    Spacer()
                    if book.rating > 0 {
                        Label("\(book.rating) / 5", systemImage: "star.fill")
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ink)
                .padding(14)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 4))

                if !book.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.3)
                            .foregroundStyle(ink.opacity(0.55))
                        Text(book.notes)
                            .font(.system(size: 15))
                            .foregroundStyle(ink)
                            .lineSpacing(4)
                    }
                }

                Text("ADDED \(book.dateAdded.formatted(date: .abbreviated, time: .omitted).uppercased())")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.8)
                    .foregroundStyle(ink.opacity(0.45))
            }
            .padding(22)
        }
        .background(paper.ignoresSafeArea())
        .navigationTitle("Book details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit") { showingEditor = true }
                    .accessibilityIdentifier("editBookButton")
                Button {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .accessibilityLabel("Delete book")
                .accessibilityIdentifier("deleteBookButton")
            }
        }
        .confirmationDialog("Delete this book?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(book)
                dismiss()
            }
            .accessibilityIdentifier("confirmDeleteBookButton")
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingEditor) {
            BookEditorView(book: book)
        }
        .tint(ink)
    }
}