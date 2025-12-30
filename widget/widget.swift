import WidgetKit
import SwiftUI
import Foundation

struct UVItem: Identifiable {
    let id: String
    let name: String
    let index: Double
    let time: String
    
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await buildEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await buildEntry()
            print("[Widget] Built entry at: \(Date()) with items: \(entry.items.count)")

            // Adapted for 1-minute updates
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            print("[Widget] Scheduling next update at: \(nextUpdate)")
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func normalizeCityKey(_ city: String) -> String {
        city.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func buildEntry() async -> SimpleEntry {
        let selectedCity = SelectedCityManager.get()
     
        let items = (try? await fetchUVItems()) ?? []
        let filtered: [UVItem]
        if let city = selectedCity {
            let key = normalizeCityKey(city)
            filtered = items.filter {
                normalizeCityKey($0.name) == key || normalizeCityKey($0.id) == key
            }
        } else {
            filtered = []
        }
        return SimpleEntry(date: Date(), items: Array(filtered.prefix(1)))
    }

    private func fetchUVItems() async throws -> [UVItem] {
        // Cache-busting query + request policy to avoid stale data
        var components = URLComponents(string: "https://uvdata.arpansa.gov.au/xml/uvvalues.xml")!
        components.queryItems = [URLQueryItem(name: "t", value: String(Int(Date().timeIntervalSince1970)))]
        var request = URLRequest(url: components.url!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try UVWidgetXMLParser().parse(data: data)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [UVItem]
}

struct widgetEntryView: View {
    var entry: Provider.Entry
    
   

    var body: some View {
        GeometryReader { proxy in
            let maxSide = min(proxy.size.width, proxy.size.height)
            let uvFontSize = maxSide * 0.5
            ZStack {
                Color.clear
                if let item = entry.items.first {
                    VStack(spacing: 6) {
                        Spacer(minLength: 0)
                        Text(String(format: "%.1f", item.index))
                            .font(.system(size: uvFontSize, weight: .heavy, design: .rounded))
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(colorForIndex(item.index))
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(entry.date, style: .time)
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                } else {
                    VStack(spacing: 6) {
                        Spacer(minLength: 0)
                        Text("Select a city in the app")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                }
            }
        }
    }
}

struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                widgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                widgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("UV Index")
        .description("Shows UV index for your selected city.")
    }
}

func colorForIndex(_ index: Double) -> Color {
    switch index {
    case 0..<3: return .green
    case 3..<6: return .yellow
    case 6..<8: return .orange
    case 8..<11: return .red
    default: return .purple
    }
}

final class UVWidgetXMLParser: NSObject, XMLParserDelegate {
    private var items: [UVItem] = []
    private var currentLocationId = ""
    private var currentIndex = ""
    private var currentTime = ""
    private var foundCharacters = ""
    private var parseError: Error?
    
    func parse(data: Data) throws -> [UVItem] {
        items = []
        parseError = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() { return items }
        if let error = parseError ?? parser.parserError { throw error }
        throw NSError(domain: "UVWidgetXMLParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown XML parsing error"])
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        foundCharacters = ""
        if elementName == "location" {
            currentLocationId = attributeDict["id"] ?? ""
            currentIndex = ""
            currentTime = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "index": currentIndex = foundCharacters
        case "time": currentTime = foundCharacters
        case "location":
            if !currentLocationId.isEmpty {
                let id = currentLocationId.replacingOccurrences(of: " ", with: "_").lowercased()
                let item = UVItem(id: id, name: currentLocationId, index: Double(currentIndex) ?? 0.0, time: currentTime)
                items.append(item)
            }
        default: break
        }
        foundCharacters = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) { self.parseError = parseError }
}

final class LastUVIndexStore {
    private static let suite = UserDefaults(suiteName: "group.uvdata") // Replace with your App Group ID
    private static func makeKey(_ city: String) -> String { "LastUVIndex_\(city)" }
    
    static func get(for city: String) -> Double? {
        suite?.object(forKey: makeKey(city)) as? Double
    }
    
    static func set(_ index: Double, for city: String) {
        suite?.set(index, forKey: makeKey(city))
    }
}

