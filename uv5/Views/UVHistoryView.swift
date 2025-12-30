import SwiftUI
import Charts

struct UVHistoryView: View {
    @StateObject private var viewModel: UVHistoryViewModel

    init(city: String?) {
        _viewModel = StateObject(wrappedValue: UVHistoryViewModel(city: city))
    }
    
    var body: some View {
        VStack {
            Text("Today's UV Index History")
                .font(.headline)
            
            if viewModel.todaysHistory.isEmpty {
                Text("No data available for today.")
                    .padding()
            } else {
                Chart(viewModel.todaysHistory, id: \.timestamp) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("UV Index", dataPoint.uv)
                    )
                    .foregroundStyle(UVIndexHelper.colorForIndex(dataPoint.uv))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
                .padding()
            }
        }
    }
}

struct UVHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        UVHistoryView(city: "Sydney")
    }
}
