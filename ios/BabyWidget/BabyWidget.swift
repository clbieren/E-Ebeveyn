import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        return Timeline(entries: [SimpleEntry(date: Date(), configuration: configuration)], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BabyWidgetEntryView : View {
    var entry: Provider.Entry
    
    @AppStorage("widget_title_text", store: UserDefaults(suiteName: "group.com.example.babycare")) 
    var title: String = "Bebeğim'in Durumu"
    
    @AppStorage("child_id", store: UserDefaults(suiteName: "group.com.example.babycare")) 
    var childId: String = ""
    
    @AppStorage("ai_insight", store: UserDefaults(suiteName: "group.com.example.babycare")) 
    var insight: String = "Yükleniyor..."
    
    @AppStorage("sleep_btn_text", store: UserDefaults(suiteName: "group.com.example.babycare")) 
    var sleepBtnText: String = "💤 Uyut"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Header
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 238/255, green: 238/255, blue: 238/255))
            
            Divider().background(Color(white: 0.2))
            
            // AI Insight
            Text(insight)
                .font(.footnote)
                .foregroundColor(Color(white: 0.6))
                .lineLimit(2)
                .padding(.bottom, 4)
            
            Spacer(minLength: 0)
            
            // Buttons
            HStack(spacing: 8) {
                // Süt Button
                Button(intent: FeedActionIntent(feedType: "breast_milk", childId: childId)) {
                    Text("🥛 Süt")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(red: 0/255, green: 32/255, blue: 30/255))
                        .background(Color(red: 128/255, green: 203/255, blue: 196/255))
                        .cornerRadius(12)
                }
                
                // Mama Button
                Button(intent: FeedActionIntent(feedType: "formula", childId: childId)) {
                    Text("🍼 Mama")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(red: 0/255, green: 32/255, blue: 30/255))
                        .background(Color(red: 128/255, green: 203/255, blue: 196/255))
                        .cornerRadius(12)
                }
                
                // Sleep Button
                Button(intent: SleepActionIntent(childId: childId)) {
                    Text(sleepBtnText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(red: 26/255, green: 16/255, blue: 48/255))
                        .background(Color(red: 179/255, green: 157/255, blue: 219/255))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        // Premium Dark Theme Background
        .containerBackground(Color(red: 13/255, green: 13/255, blue: 13/255), for: .widget)
    }
}

// Widget Kaydı
struct BabyWidget: Widget {
    let kind: String = "BabyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BabyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Baby Tracker Interaktif")
        .description("Bebeğinizin durumunu görün ve anında kayıt atın.")
        .supportedFamilies([.systemMedium]) // Orta boy idealdir
    }
}

struct ConfigurationAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Configuration"
}
