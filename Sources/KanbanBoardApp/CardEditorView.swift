import KanbanCore
import SwiftUI

enum CardEditorMode: Identifiable {
    case add
    case edit(CardModel)

    var id: String {
        switch self {
        case .add:
            "add"
        case .edit(let card):
            card.id.uuidString
        }
    }

    var title: String {
        switch self {
        case .add: "Add Card"
        case .edit: "Edit Card"
        }
    }
}

struct CardEditorResult {
    let mode: CardEditorMode
    let title: String
    let notes: String
    let status: CardStatus
    let priority: CardPriority
    let tags: [String]
    let dueDate: Date?
}

struct CardEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: CardEditorMode
    let onSave: (CardEditorResult) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var status: CardStatus
    @State private var priority: CardPriority
    @State private var tagsText: String
    @State private var dueDateText: String
    @State private var validationMessage: String?

    init(mode: CardEditorMode, onSave: @escaping (CardEditorResult) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .add:
            _title = State(initialValue: "")
            _notes = State(initialValue: "")
            _status = State(initialValue: .todo)
            _priority = State(initialValue: .medium)
            _tagsText = State(initialValue: "")
            _dueDateText = State(initialValue: "")
        case .edit(let card):
            _title = State(initialValue: card.title)
            _notes = State(initialValue: card.notes)
            _status = State(initialValue: card.status)
            _priority = State(initialValue: card.priority)
            _tagsText = State(initialValue: card.tags.joined(separator: ", "))
            _dueDateText = State(initialValue: card.dueDate.map(DayDateParser.string(from:)) ?? "")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(mode.title)
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("card-title-field")

            TextField("Notes", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
                .accessibilityIdentifier("card-notes-field")

            HStack {
                Picker("Status", selection: $status) {
                    ForEach(CardStatus.allCases) { status in
                        Text(status.displayName).tag(status)
                    }
                }
                .accessibilityIdentifier("card-status-picker")

                Picker("Priority", selection: $priority) {
                    ForEach(CardPriority.allCases) { priority in
                        Text(priority.displayName).tag(priority)
                    }
                }
                .accessibilityIdentifier("card-priority-picker")
            }

            TextField("Tags, comma separated", text: $tagsText)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("card-tags-field")

            TextField("Due date yyyy-MM-dd", text: $dueDateText)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("card-due-field")

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("card-validation-message")
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("save-card-button")
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private func save() {
        do {
            let dueDate = dueDateText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : try DayDateParser.parse(dueDateText)
            _ = try KanbanCardDraft(
                title: title,
                notes: notes,
                status: status,
                priority: priority,
                tags: splitTags,
                dueDate: dueDate
            )

            onSave(CardEditorResult(
                mode: mode,
                title: title,
                notes: notes,
                status: status,
                priority: priority,
                tags: splitTags,
                dueDate: dueDate
            ))
            dismiss()
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    private var splitTags: [String] {
        tagsText.split(separator: ",").map { String($0) }
    }
}
