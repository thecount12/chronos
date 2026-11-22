//
//  ChronosEngine.swift
//  Chronos
//
//  Created by William Gunnells on 11/22/26.
//

import SwiftUI

struct PlanetInfo: Identifiable {
    let id: Int
    let name: String
    let root: Int
    let archangel: String
    let spirit: String
    let color: Color
    let glyph: String
}

struct ChronosEngine {
    let date: Date
    let anchorDate: Date
    
    // MARK: - Dual Time (Metric Centidays + Standard HH:mm:ss)
    var centidays: Double {
        let cal = Calendar.current
        let h = Double(cal.component(.hour, from: date))
        let m = Double(cal.component(.minute, from: date))
        let s = Double(cal.component(.second, from: date))
        return ((s / 86400.0) + (m / 1440.0) + (h / 24.0)) * 100.0
    }
    
    var formattedMetric: String {
        String(format: "%05.2f", centidays)
    }
    
    var formattedStandard: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // MARK: - Macro Cycles (10-Day Dekade, 20-Day Sprint, 100-Day Arc, 365-Day Solar)
    var personalDays: Int {
        let cal = Calendar.current
        let startAnchor = cal.startOfDay(for: anchorDate)
        let startToday = cal.startOfDay(for: date)
        return max(0, cal.dateComponents([.day], from: startAnchor, to: startToday).day ?? 0)
    }
    
    var dekadeDay: Int { (personalDays % 10) + 1 }
    var twentyDaySprint: Int { (personalDays % 20) + 1 }
    var hundredDayArc: Int { (personalDays % 100) + 1 }
    var solarYearArc: Int { (personalDays % 365) + 1 }
    
    // MARK: - Pythagorean Planetary Matrix
    static func planet(forRoot root: Int) -> PlanetInfo {
        switch root {
        case 1: return PlanetInfo(id: 1, name: "Sun", root: 1, archangel: "Michael", spirit: "Och", color: Color(red: 0.96, green: 0.62, blue: 0.04), glyph: "☉")
        case 2: return PlanetInfo(id: 2, name: "Moon", root: 2, archangel: "Gabriel", spirit: "Phul", color: Color(red: 0.58, green: 0.64, blue: 0.72), glyph: "☽")
        case 3: return PlanetInfo(id: 3, name: "Jupiter", root: 3, archangel: "Sachiel", spirit: "Bethor", color: Color(red: 0.23, green: 0.51, blue: 0.96), glyph: "♃")
        case 5: return PlanetInfo(id: 5, name: "Mercury", root: 5, archangel: "Raphael", spirit: "Ophiel", color: Color(red: 0.06, green: 0.73, blue: 0.51), glyph: "☿")
        case 6: return PlanetInfo(id: 6, name: "Venus", root: 6, archangel: "Anael", spirit: "Hagith", color: Color(red: 0.93, green: 0.28, blue: 0.60), glyph: "♀")
        case 8: return PlanetInfo(id: 8, name: "Saturn", root: 8, archangel: "Cassiel", spirit: "Aratron", color: Color(red: 0.55, green: 0.36, blue: 0.96), glyph: "♄")
        case 9: return PlanetInfo(id: 9, name: "Mars", root: 9, archangel: "Samael", spirit: "Phaleg", color: Color(red: 0.94, green: 0.27, blue: 0.27), glyph: "♂")
        default: return PlanetInfo(id: 0, name: "Unknown", root: 0, archangel: "None", spirit: "None", color: .gray, glyph: "✦")
        }
    }
    
    var dayPlanet: PlanetInfo {
        // Calendar weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let weekday = Calendar.current.component(.weekday, from: date)
        let map = [1: 1, 2: 2, 3: 9, 4: 5, 5: 3, 6: 6, 7: 8]
        return Self.planet(forRoot: map[weekday] ?? 1)
    }
    
    var planetaryHour: PlanetInfo {
        // Chaldean descending order mapped to Pythagorean roots:
        // Saturn(8), Jupiter(3), Mars(9), Sun(1), Venus(6), Mercury(5), Moon(2)
        let chaldeanRoots = [8, 3, 9, 1, 6, 5, 2]
        let cal = Calendar.current
        var hour = cal.component(.hour, from: date)
        var effectiveDate = date
        
        if hour < 6 {
            effectiveDate = cal.date(byAdding: .day, value: -1, to: date) ?? date
            hour += 24
        }
        let hoursSinceSunrise = hour - 6
        let weekday = cal.component(.weekday, from: effectiveDate)
        let thursdayOffset = (weekday + 2) % 7
        let dayStartIndex = (thursdayOffset * 3 + 1) % 7
        return Self.planet(forRoot: chaldeanRoots[(dayStartIndex + hoursSinceSunrise) % 7])
    }

    
    // MARK: - Obsidian YAML Export
    func toObsidianYAML() -> String {
        let d = dayPlanet
        let h = planetaryHour
        return """
        ---
        metric_time: \(formattedMetric) LMT
        standard_time: \(formattedStandard)
        dekade_day: \(dekadeDay)
        twenty_sprint: \(twentyDaySprint)
        hundred_arc: \(hundredDayArc)
        solar_arc: \(solarYearArc)
        day_planet: \(d.name)
        day_root: \(d.root)
        hour_planet: \(h.name)
        hour_root: \(h.root)
        ---
        """
    }
}
