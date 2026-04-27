import SwiftUI

enum RootTab: Hashable { case list, almanac, chart, observer, compare }

struct RootView: View {
    @State private var observerStore = ObserverStore()
    @State private var listVM: BodiesListViewModel
    @State private var almanacVM: AlmanacViewModel
    @State private var chartVM: ChartViewModel
    @State private var compareVM: CompareViewModel
    @State private var selection: RootTab = .list

    init() {
        let store = ObserverStore()
        _observerStore = State(initialValue: store)
        _listVM     = State(initialValue: BodiesListViewModel(observerStore: store))
        _almanacVM  = State(initialValue: AlmanacViewModel())
        _chartVM    = State(initialValue: ChartViewModel(observerStore: store))
        _compareVM  = State(initialValue: CompareViewModel(observerStore: store))
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            BrutalistTabBar(
                selection: $selection,
                items: [
                    .init(id: .list,     title: "Bodies"),
                    .init(id: .almanac,  title: "Almanac"),
                    .init(id: .chart,    title: "Chart"),
                    .init(id: .observer, title: "Observer"),
                    .init(id: .compare,  title: "Compare")
                ]
            )
        }
        .background(BrutalistTheme.background.ignoresSafeArea())
        .onAppear {
            listVM.observerStore = observerStore
            chartVM.observerStore = observerStore
            compareVM.observerStore = observerStore
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .list:
            NavigationStack {
                BodiesListView(viewModel: listVM)
                    .navigationDestination(for: CelestialBodyID.self) { id in
                        BodyDetailView(viewModel:
                            BodyDetailViewModel(bodyID: id, observerStore: observerStore))
                    }
            }
        case .almanac:  AlmanacView(viewModel: almanacVM)
        case .chart:
            NavigationStack {
                ChartView(viewModel: chartVM)
                    .navigationDestination(for: CelestialBodyID.self) { id in
                        BodyDetailView(viewModel:
                            BodyDetailViewModel(bodyID: id, observerStore: observerStore))
                    }
            }
        case .observer: ObserverInputView(store: observerStore)
        case .compare:  CompareView(viewModel: compareVM)
        }
    }
}

#Preview {
    RootView()
}
