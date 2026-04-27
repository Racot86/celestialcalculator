import SwiftUI

struct RootView: View {
    @State private var observerStore = ObserverStore()
    @State private var detailVM: BodyDetailViewModel
    @State private var listVM: BodiesListViewModel
    @State private var compareVM: CompareViewModel

    init() {
        let store = ObserverStore()
        _observerStore = State(initialValue: store)
        _detailVM  = State(initialValue: BodyDetailViewModel(observerStore: store))
        _listVM    = State(initialValue: BodiesListViewModel(observerStore: store))
        _compareVM = State(initialValue: CompareViewModel(observerStore: store))
    }

    var body: some View {
        TabView {
            BodyDetailView(viewModel: detailVM)
                .tabItem { Label("Detail", systemImage: "scope") }

            BodiesListView(viewModel: listVM)
                .tabItem { Label("List", systemImage: "list.bullet.rectangle") }

            ObserverInputView(store: observerStore)
                .tabItem { Label("Observer", systemImage: "location.viewfinder") }

            CompareView(viewModel: compareVM)
                .tabItem { Label("Compare", systemImage: "checkmark.shield") }
        }
        .tint(BrutalistTheme.accent)
        .onAppear {
            detailVM.observerStore = observerStore
            listVM.observerStore = observerStore
            compareVM.observerStore = observerStore
        }
    }
}

#Preview {
    RootView()
}
