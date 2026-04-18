import AppIntents
import home_widget

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct FeedActionIntent: AppIntent {
    public static var title: LocalizedStringResource = "Log Feed"
    
    @Parameter(title: "Feed Type")
    var feedType: String
    
    @Parameter(title: "Child ID")
    var childId: String

    public init() {}
    public init(feedType: String, childId: String) {
        self.feedType = feedType
        self.childId = childId
    }

    public func perform() async throws -> some IntentResult {
        await HomeWidgetBackgroundWorker.run(
            url: URL(string: "babycare://log_feed?type=\(feedType)&child_id=\(childId)"),
            appGroup: "group.com.example.babycare"
        )
        return .result()
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct SleepActionIntent: AppIntent {
    public static var title: LocalizedStringResource = "Toggle Sleep"
    
    @Parameter(title: "Child ID")
    var childId: String

    public init() {}
    public init(childId: String) {
        self.childId = childId
    }

    public func perform() async throws -> some IntentResult {
        await HomeWidgetBackgroundWorker.run(
            url: URL(string: "babycare://toggle_sleep?child_id=\(childId)"),
            appGroup: "group.com.example.babycare"
        )
        return .result()
    }
}
