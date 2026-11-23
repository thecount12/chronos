//
//  ChronosComplication.swift
//  ChronosComplication
//
//  Created by William Gunnells on 11/22/26.
//

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
        
        // Schedule 20 updates spaced 1.0 centiday (864 seconds = 14.4 mins) apart
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

struct ChronosComplicationEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    private var anchorDate: Date {
        let month = UserDefaults.standard.integer(forKey: "birthMonth")
        let day = UserDefaults.standard.integer(forKey: "birthDay")
        return ChronosEngine.mostRecentBirthday(
            month: month > 0 ? month : 5,
            day: day > 0 ? day : 18,
            relativeTo: entry.date
        )
    }

    var body: some View {
        let engine = ChronosEngine(date: entry.date, anchorDate: anchorDate)
        let dPlanet = engine.dayPlanet
        let hPlanet = engine.planetaryHour
        
        switch family {
        case .accessoryCircular:
            // Circular Watch Face Gauge: Metric Ring + Dual Time Center
            Gauge(value: engine.centidays, in: 0...100) {
                Text("\(dPlanet.glyph)\u{FE0E}\(hPlanet.glyph)\u{FE0E}")
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
                    Text("\(dPlanet.glyph)\u{FE0E}")
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
                    
                    Text("\(dPlanet.glyph)\u{FE0E} \(dPlanet.name) • \(hPlanet.glyph)\u{FE0E} \(hPlanet.name)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(hPlanet.color)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct ChronosComplication: Widget {
    let kind: String = "ChronosComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ChronosComplicationEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Chronos Dual Time")
        .description("Live Metric LMT, Standard Time, and Planetary Rulers.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

#Preview(as: .accessoryRectangular) {
    ChronosComplication()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
}
