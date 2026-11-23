import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Schedule 20 entries spaced 1 centiday (864 seconds = 14.4 mins) apart
        for step in 0 ..< 20 {
            let entryDate = currentDate.addingTimeInterval(Double(step) * 864.0)
            entries.append(SimpleEntry(date: entryDate, configuration: configuration))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Chronos Dual Time")]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct ChronosWatchEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    private var anchorDate: Date {
        let ts = UserDefaults.standard.double(forKey: "anchorTimestamp")
        if ts > 0 { return Date(timeIntervalSince1970: ts) }
        return Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date()
    }

    var body: some View {
        let engine = ChronosEngine(date: entry.date, anchorDate: anchorDate)
        let dPlanet = engine.dayPlanet
        let hPlanet = engine.planetaryHour
        
        switch family {
        case .accessoryCircular:
            // Circular Watch Face Gauge: Metric Ring + Dual Time Center
            Gauge(value: engine.centidays, in: 0...100) {
                Text("\(dPlanet.glyph)\(hPlanet.glyph)")
            } currentValueLabel: {
                Text(String(format: "%.0f", engine.centidays))
                    .font(.system(.body, design: .rounded).bold())
            }
            .gaugeStyle(.accessoryCircular)
            .tint(dPlanet.color)
            
        case .accessoryCorner:
            // Corner Watch Face Complication
            Text("\(engine.formattedMetric) LMT")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundStyle(.cyan)
                .widgetLabel {
                    Gauge(value: engine.centidays, in: 0...100) {
                        Text(engine.formattedStandard)
                    }
                    .tint(dPlanet.color)
                }
                
        default:
            // Rectangular Watch Face / Smart Stack Card
            HStack(spacing: 10) {
                Gauge(value: engine.centidays, in: 0...100) {
                    Text(dPlanet.glyph)
                } currentValueLabel: {
                    Text("D\(engine.dekadeDay)")
                        .font(.caption2.bold())
                }
                .gaugeStyle(.accessoryCircular)
                .tint(dPlanet.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(engine.formattedMetric) LMT")
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundStyle(.cyan)
                    
                    Text(entry.date, style: .time)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                    
                    Text("\(dPlanet.glyph) \(dPlanet.name) • \(hPlanet.glyph) \(hPlanet.name)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(hPlanet.color)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct ChronosWatch: Widget {
    let kind: String = "ChronosWatch"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ChronosWatchEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Chronos Dual Time")
        .description("Live Metric LMT, Standard Time, and Planetary Rulers.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

#Preview(as: .accessoryRectangular) {
    ChronosWatch()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
}
