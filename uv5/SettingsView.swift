import SwiftUI

struct SettingsView: View {
    let cities: [String]
    let currentCity: String?
    let onSelect: (String) -> Void
    @State private var selectedCity: String
    @Environment(\.dismiss) private var dismiss

    init(cities: [String], currentCity: String?, onSelect: @escaping (String) -> Void) {
        self.cities = cities
        self.currentCity = currentCity
        self.onSelect = onSelect
        _selectedCity = State(initialValue: currentCity ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("City") {
                    Picker("City", selection: $selectedCity) {
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("UV Index App")
                            .font(.headline)
                        Text("View current UV index, description, and recent history. Change your city from here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("By David Sebbag")
                        Spacer()
                        Link("Github", destination: URL(string: "https://github.com/Davdadev")!)
                    }
                }

                Section("Sources") {
                    Link("UV data from ARPANSA", destination: URL(string: "https://www.arpansa.gov.au/our-services/monitoring/ultraviolet-radiation-monitoring/ultraviolet-radation-data-information#Disclaimer")!)
                    Link("UV Data History", destination: URL(string: "https://davdadev.github.io/uvdata-history/raw")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSelect(selectedCity)
                        dismiss()
                    }
                }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
        return "\(version) (Build \(build))"
    }
}

#Preview {
    SettingsView(cities: ["San Francisco", "New York", "London"], currentCity: "San Francisco") { _ in }
}
