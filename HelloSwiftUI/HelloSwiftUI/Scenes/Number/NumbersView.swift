//
//  NumberView.swift
//  HelloSwiftUI
//
//  Created by jun.kohda on 2023/10/31.
//

import SwiftUI
import Combine

struct NumbersView: View {
    @StateObject private var viewModel = NumbersViewModel()
    
    var body: some View {
        NavigationView {
            NumbersListView(viewModel: viewModel)
                .navigationTitle("Numbers")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("アラート"),
                message: Text("\(viewModel.selectedNumber ?? 0)"),
                primaryButton: .default(Text("キャンセル")),
                secondaryButton: .default(Text("OK"))
            )
        }
    }
}

private struct NumbersListView: View {
    @ObservedObject var viewModel: NumbersViewModel
    
    var body: some View {
        List(viewModel.numbers.indices, id: \.self) { index in
            NumbersItemView(viewModel: viewModel, index: index)
                .onAppear {
                    if index == viewModel.numbers.count - 1 && !viewModel.isLoading {
                        viewModel.loadMoreData()
                    }
                }
        }
    }
}

private struct NumbersItemView: View {
    @ObservedObject var viewModel: NumbersViewModel
    let index: Int
    
    var body: some View {
        Button(
            action: {
                viewModel.showAlertFor(number: viewModel.numbers[index])
            },
            label: {
                Text("\(viewModel.numbers[index])")
                    .foregroundColor(Color.black)
            }
        )
    }
}

class NumbersViewModel: ObservableObject {
    @Published var numbers: [Int] = []
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var selectedNumber: Int?
    private var currentPage = 1
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMoreData()
    }
    
    func loadMoreData() {
        isLoading = true
        fetchData(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                case .finished:
                    self.isLoading = false
                }
            } receiveValue: { fetchedNumbers in
                DispatchQueue.main.async {
                    self.numbers.append(contentsOf: fetchedNumbers)
                    self.currentPage += 1
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchData(page: Int) -> Future<[Int], Error> {
        Future { promise in
            var urlComponents = URLComponents(string: "https://mobile.app.hub.com/items")!
            urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
            
            let task = URLSession.shared.dataTask(with: urlComponents.url!) { data, _, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"])
                    promise(.failure(error))
                    return
                }
                
                do {
                    let fetchedNumbers = try JSONDecoder().decode([Int].self, from: data)
                    promise(.success(fetchedNumbers))
                } catch {
                    promise(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    func showAlertFor(number: Int) {
        self.selectedNumber = number
        self.showAlert = true
    }
}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NumbersView()
    }
}
