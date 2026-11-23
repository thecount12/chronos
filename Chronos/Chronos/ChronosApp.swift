//
//  ChronosApp.swift
//  Chronos
//
//  Created by William Gunnells on 11/22/26.
//

import SwiftUI
import Combine
#if os(macOS)
import AppKit
#endif

@main
struct ChronosApp: App {
    @State private var now = Date()
    @AppStorage("anchorTimestamp") private var anchorTimestamp: Double = {
        ChronosEngine.mostRecentBirthday(month: 5, day: 18).timeIntervalSince1970
    }()
    @AppStorage("obsidianVaultPath") private var obsidianVaultPath: String = ""
    @State private var statusMessage: String = ""
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(timer) { input in now = input }
        }
        
        #if os(macOS)
        MenuBarExtra {
            let engine = ChronosEngine(date: now, anchorDate: Date(timeIntervalSince1970: anchorTimestamp))
            let d = engine.dayPlanet
            let h = engine.planetaryHour
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Metric: \(engine.formattedMetric) LMT")
                    .font(.headline.monospaced())
                Text("Standard: \(engine.formattedStandard)")
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Text("Day: \(d.glyph) \(d.name) [\(d.root)] (\(d.archangel))")
                Text("Hour: \(h.glyph) \(h.name) [\(h.root)] (\(h.archangel))")
                Text("Dekade \(engine.dekadeDay)/10 • Sprint \(engine.twentyDaySprint)/20 • Solar \(engine.solarYearArc)/365")
                    .font(.caption)
                
                Divider()
                
                Button("Stamp Today's Obsidian Note") {
                    stampObsidianNote(engine: engine)
                }
                
                Button(obsidianVaultPath.isEmpty ? "Choose Obsidian Folder..." : "Change Obsidian Folder...") {
                    chooseObsidianFolder()
                }
                
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                }
                
                Divider()
                Button("Quit Chronos") { NSApplication.shared.terminate(nil) }
            }
            .padding(10)
        } label: {
            let engine = ChronosEngine(date: now, anchorDate: Date(timeIntervalSince1970: anchorTimestamp))
            Text("\(engine.formattedMetric) LMT • \(engine.dayPlanet.glyph)")
        }
        #endif
    }
    
    #if os(macOS)
    private func chooseObsidianFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Obsidian Daily Notes Folder"
        if panel.runModal() == .OK, let url = panel.url {
            obsidianVaultPath = url.path
            statusMessage = "Saved: \(url.lastPathComponent)"
        }
    }
    
    private func stampObsidianNote(engine: ChronosEngine) {
        if obsidianVaultPath.isEmpty {
            chooseObsidianFolder()
        }
        guard !obsidianVaultPath.isEmpty else { return }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let fileName = "\(df.string(from: now)).md"
        let fileURL = URL(fileURLWithPath: obsidianVaultPath).appendingPathComponent(fileName)
        
        let stamp = "\n\(engine.toObsidianYAML())\n"
        if FileManager.default.fileExists(atPath: fileURL.path),
           let existing = try? String(contentsOf: fileURL, encoding: .utf8) {
            try? (existing + stamp).write(to: fileURL, atomically: true, encoding: .utf8)
            statusMessage = "Appended to \(fileName)"
        } else {
            try? stamp.write(to: fileURL, atomically: true, encoding: .utf8)
            statusMessage = "Created \(fileName)"
        }
    }
    #endif
}
