import SwiftData
import SwiftUI

@main
struct KanbanBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: CardModel.self)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Kanban Card") {
                    NotificationCenter.default.post(name: .newCardRequested, object: nil)
                }
                .keyboardShortcut("n")
            }
        }
    }
}

extension Notification.Name {
    static let newCardRequested = Notification.Name("newCardRequested")
}
