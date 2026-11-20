import SwiftData
import SwiftUI

@main
struct ReadingShelfApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: Book.self,
            inMemory: ProcessInfo.processInfo.arguments.contains("-ui-testing")
        )
    }
}