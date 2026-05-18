import KanbanCore
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CardModel]

    @State private var searchText = ""
    @State private var selectedPriority: CardPriority?
    @State private var tagFilter = ""
    @State private var editorMode: CardEditorMode?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            toolbar

            Divider()

            HStack(alignment: .top, spacing: 12) {
                ForEach(CardStatus.allCases) { status in
                    KanbanColumnView(
                        status: status,
                        cards: filteredCards(for: status),
                        onEdit: { editorMode = .edit($0) },
                        onDelete: delete,
                        onMove: move
                    )
                }
            }
            .padding(16)
        }
        .frame(minWidth: 980, minHeight: 620)
        .sheet(item: $editorMode) { mode in
            CardEditorView(mode: mode) { result in
                save(result)
            }
        }
        .alert("Kanban Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            resetStoreIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newCardRequested)) { _ in
            editorMode = .add
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Text("Mini Kanban Board")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            TextField("Search", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 220)
                .accessibilityIdentifier("search-field")

            Picker("Priority", selection: $selectedPriority) {
                Text("Any Priority").tag(Optional<CardPriority>.none)
                ForEach(CardPriority.allCases) { priority in
                    Text(priority.displayName).tag(Optional(priority))
                }
            }
            .frame(width: 160)
            .accessibilityIdentifier("priority-filter")

            TextField("Tag", text: $tagFilter)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .accessibilityIdentifier("tag-filter-field")

            Button {
                editorMode = .add
            } label: {
                Label("Add Card", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("add-card-button")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func filteredCards(for status: CardStatus) -> [CardModel] {
        cards
            .filter { $0.status == status }
            .filter {
                $0.matches(
                    query: searchText,
                    priority: selectedPriority,
                    tag: tagFilter
                )
            }
            .sorted { lhs, rhs in
                if lhs.priority.sortRank != rhs.priority.sortRank {
                    return lhs.priority.sortRank < rhs.priority.sortRank
                }

                switch (lhs.dueDate, rhs.dueDate) {
                case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
                    return lhsDate < rhsDate
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                default:
                    return lhs.updatedAt > rhs.updatedAt
                }
            }
    }

    private func save(_ result: CardEditorResult) {
        do {
            switch result.mode {
            case .add:
                let card = CardModel(
                    title: result.title,
                    notes: result.notes,
                    status: result.status,
                    priority: result.priority,
                    tags: result.tags,
                    dueDate: result.dueDate
                )
                modelContext.insert(card)
            case .edit(let card):
                try card.apply(
                    title: result.title,
                    notes: result.notes,
                    status: result.status,
                    priority: result.priority,
                    tags: result.tags,
                    dueDate: result.dueDate
                )
            }

            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func move(_ card: CardModel, _ status: CardStatus) {
        card.status = status
        saveContext()
    }

    private func delete(_ card: CardModel) {
        modelContext.delete(card)
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetStoreIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("--uitesting-reset-store") else {
            return
        }

        do {
            let descriptor = FetchDescriptor<CardModel>()
            for card in try modelContext.fetch(descriptor) {
                modelContext.delete(card)
            }
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct KanbanColumnView: View {
    let status: CardStatus
    let cards: [CardModel]
    let onEdit: (CardModel) -> Void
    let onDelete: (CardModel) -> Void
    let onMove: (CardModel, CardStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(status.displayName)
                    .font(.headline)
                Spacer()
                Text("\(cards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .accessibilityIdentifier("\(status.rawValue)-count")
            }

            if cards.isEmpty {
                ContentUnavailableView("No Cards", systemImage: "square.dashed")
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .accessibilityIdentifier("\(status.rawValue)-empty-state")
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(cards) { card in
                            CardRowView(
                                card: card,
                                onEdit: onEdit,
                                onDelete: onDelete,
                                onMove: onMove
                            )
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("column-\(status.rawValue)")
    }
}

private struct CardRowView: View {
    let card: CardModel
    let onEdit: (CardModel) -> Void
    let onDelete: (CardModel) -> Void
    let onMove: (CardModel, CardStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(card.title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer()
                Text(card.priority.displayName)
                    .font(.caption)
                    .foregroundStyle(priorityColor)
            }

            if !card.notes.isEmpty {
                Text(card.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            if !card.tags.isEmpty || card.dueDate != nil {
                HStack(spacing: 6) {
                    ForEach(card.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    if let dueDate = card.dueDate {
                        Text(DayDateParser.string(from: dueDate))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack(spacing: 6) {
                Button {
                    onMove(card, card.status.nextStatus)
                } label: {
                    Label("Advance", systemImage: "arrow.right.circle")
                }
                .accessibilityIdentifier("advance-card-button-\(card.title)")

                Menu {
                    ForEach(CardStatus.allCases.filter { $0 != card.status }) { status in
                        Button(status.displayName) {
                            onMove(card, status)
                        }
                        .accessibilityIdentifier("move-\(status.rawValue)-button")
                    }
                } label: {
                    Label("Move", systemImage: "arrow.right")
                }
                .accessibilityIdentifier("move-card-button-\(card.title)")

                Button {
                    onEdit(card)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .accessibilityIdentifier("edit-card-button-\(card.title)")

                Button(role: .destructive) {
                    onDelete(card)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .accessibilityIdentifier("delete-card-button-\(card.title)")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("card-\(card.status.rawValue)-\(card.title)")
    }

    private var priorityColor: Color {
        switch card.priority {
        case .high: .red
        case .medium: .orange
        case .low: .secondary
        }
    }
}

private extension CardStatus {
    var nextStatus: CardStatus {
        switch self {
        case .todo: .inProgress
        case .inProgress: .done
        case .done: .todo
        }
    }
}
