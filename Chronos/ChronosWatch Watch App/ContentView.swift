import SwiftUI
import Combine
import WatchKit

struct ContentView: View {
    @State private var now = Date()
    @State private var crownOffsetCentidays: Double = 0.0
    @FocusState private var isCrownFocused: Bool
    
    @AppStorage("birthMonth") private var birthMonth: Int = 5
    @AppStorage("birthDay") private var birthDay: Int = 18
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var anchorDate: Date {
        ChronosEngine.mostRecentBirthday(month: birthMonth, day: birthDay, relativeTo: now)
    }
    
    private var displayDate: Date {
        now.addingTimeInterval(crownOffsetCentidays * 864.0)
    }
    
    var body: some View {
        let engine = ChronosEngine(date: displayDate, anchorDate: anchorDate)
        let dPlanet = engine.dayPlanet
        let hPlanet = engine.planetaryHour
        let bounds = WKInterfaceDevice.current().screenBounds
        let diameter = min(bounds.width, bounds.height) - 4
        
        TabView {
            // PAGE 1: Edge-to-Edge Concentric Wheel
            ZStack {
                Color.black.ignoresSafeArea()
                
                ForEach(0..<10, id: \.self) { i in
                    VStack {
                        Text(String(format: "%02d", i * 10))
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(Double(i) * 36.0))
                }
                
                WatchRing(progress: engine.centidays / 100.0, color: .cyan, lineWidth: 8)
                    .frame(width: diameter - 22, height: diameter - 22)
                
                WatchRing(progress: Double(engine.twentyDaySprint) / 20.0, color: dPlanet.color, lineWidth: 7)
                    .frame(width: diameter - 38, height: diameter - 38)
                
                WatchRing(progress: Double(engine.hundredDayArc) / 100.0, color: hPlanet.color, lineWidth: 5)
                    .frame(width: diameter - 52, height: diameter - 52)
                
                VStack(spacing: 1) {
                    Text("\(dPlanet.glyph)\u{FE0E} \(hPlanet.glyph)\u{FE0E}")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(dPlanet.color)
                    
                    Text(engine.formattedMetric)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .monospacedDigit()
                    
                    Text(engine.formattedStandard)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text(crownOffsetCentidays == 0 ? "\(dPlanet.name.prefix(4)) • \(hPlanet.name.prefix(4))" : String(format: "%+.0f cd", crownOffsetCentidays))
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(crownOffsetCentidays == 0 ? hPlanet.color : .yellow)
                }
            }
            .frame(width: bounds.width, height: bounds.height)
            .ignoresSafeArea()
            .focusable()
            .focused($isCrownFocused)
            .digitalCrownRotation(
                $crownOffsetCentidays,
                from: -50.0,
                through: 50.0,
                by: 1.0,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onAppear { isCrownFocused = true }
            .onTapGesture {
                withAnimation { crownOffsetCentidays = 0.0 }
            }
            
            // PAGE 2: Planetary Telemetry & Birthday Anchor Picker
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CHRONOS TELEMETRY")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(.cyan)
                    
                    Group {
                        Text("Day: \(dPlanet.name) [\(dPlanet.root)]")
                            .foregroundStyle(dPlanet.color)
                        Text("  \(dPlanet.archangel) • \(dPlanet.spirit)")
                            .foregroundStyle(.secondary)
                        
                        Text("Hour: \(hPlanet.name) [\(hPlanet.root)]")
                            .foregroundStyle(hPlanet.color)
                        Text("  \(hPlanet.archangel) • \(hPlanet.spirit)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dekade: \(engine.dekadeDay) / 10")
                        Text("20-Sprint: \(engine.twentyDaySprint) / 20")
                        Text("100-Arc: \(engine.hundredDayArc) / 100")
                        Text("Solar Year: \(engine.solarYearArc) / 365")
                    }
                    .font(.system(size: 11, design: .monospaced))
                    
                    Divider()
                    
                    Text("Birthday Anchor (Day 1)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Picker("Month", selection: $birthMonth) {
                            ForEach(1...12, id: \.self) { m in
                                Text(Calendar.current.shortMonthSymbols[m - 1]).tag(m)
                            }
                        }
                        .frame(height: 55)
                        
                        Picker("Day", selection: $birthDay) {
                            ForEach(1...31, id: \.self) { d in
                                Text("\(d)").tag(d)
                            }
                        }
                        .frame(height: 55)
                    }
                }
                .padding(.horizontal, 6)
            }
        }
        .tabViewStyle(.verticalPage)
        .toolbar(.hidden)
        .onReceive(timer) { input in now = input }
    }
}

struct WatchRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
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
