import SwiftUI
import Combine
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ContentView: View {
    @State private var now = Date()
    @AppStorage("anchorTimestamp") private var anchorTimestamp: Double = {
        Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }()
    @State private var copiedFeedback = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var anchorBinding: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: anchorTimestamp) },
            set: { anchorTimestamp = $0.timeIntervalSince1970 }
        )
    }
    
    var body: some View {
        let engine = ChronosEngine(date: now, anchorDate: Date(timeIntervalSince1970: anchorTimestamp))
        let dPlanet = engine.dayPlanet
        let hPlanet = engine.planetaryHour
        
        ScrollView {
            VStack(spacing: 22) {
                // Concentric Wheel Canvas
                ZStack {
                    // 10 Deciday Markers
                    ForEach(0..<10, id: \.self) { i in
                        VStack {
                            Text(String(format: "%02d", i * 10))
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .frame(width: 330, height: 330)
                        .rotationEffect(.degrees(Double(i) * 36.0))
                    }
                    
                    // Outer Ring: Metric Centidays
                    ChronosRingView(progress: engine.centidays / 100.0, color: .cyan, lineWidth: 14)
                        .frame(width: 284, height: 284)
                    
                    // 2nd Ring: 20-Day Sprint
                    ChronosRingView(progress: Double(engine.twentyDaySprint) / 20.0, color: dPlanet.color, lineWidth: 12)
                        .frame(width: 246, height: 246)
                    
                    // 3rd Ring: 100-Day Arc
                    ChronosRingView(progress: Double(engine.hundredDayArc) / 100.0, color: hPlanet.color, lineWidth: 10)
                        .frame(width: 212, height: 212)
                    
                    // Inner Ring: 365-Day Solar Arc
                    ChronosRingView(progress: Double(engine.solarYearArc) / 365.0, color: .yellow, lineWidth: 8)
                        .frame(width: 182, height: 182)
                    
                    // Center Dual-Time Core
                    VStack(spacing: 3) {
                        Text("\(dPlanet.glyph) \(hPlanet.glyph)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(dPlanet.color)
                        
                        Text(engine.formattedMetric)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .monospacedDigit()
                        
                        Text("LMT • \(engine.formattedStandard)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                        
                        Text("\(dPlanet.name) [\(dPlanet.root)] / \(hPlanet.name) [\(hPlanet.root)]")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(hPlanet.color)
                    }
                }
                .padding(.top, 16)
                
                // Cycle Telemetry Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Dekade: \(engine.dekadeDay) / 10")
                        Spacer()
                        Text("20-Day Sprint: \(engine.twentyDaySprint) / 20")
                    }
                    HStack {
                        Text("100-Day Arc: \(engine.hundredDayArc) / 100")
                        Spacer()
                        Text("Solar Arc: \(engine.solarYearArc) / 365")
                    }
                    Divider()
                    Text("Day: \(dPlanet.name) (\(dPlanet.archangel) / \(dPlanet.spirit))")
                        .foregroundStyle(dPlanet.color)
                    Text("Hour: \(hPlanet.name) (\(hPlanet.archangel) / \(hPlanet.spirit))")
                        .foregroundStyle(hPlanet.color)
                }
                .font(.caption.monospaced())
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                .padding(.horizontal)
                
                // Personal Anchor DatePicker & Obsidian Copy Button
                HStack(spacing: 12) {
                    DatePicker("Anchor", selection: anchorBinding, displayedComponents: .date)
                        .labelsHidden()
                    
                    Button {
                        copyToClipboard(engine.toObsidianYAML())
                        copiedFeedback = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedFeedback = false
                        }
                    } label: {
                        Label(copiedFeedback ? "Copied YAML!" : "Copy Obsidian YAML", systemImage: copiedFeedback ? "checkmark" : "doc.on.doc")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .preferredColorScheme(.dark)
        .onReceive(timer) { input in now = input }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

struct ChronosRingView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    ContentView()
}

