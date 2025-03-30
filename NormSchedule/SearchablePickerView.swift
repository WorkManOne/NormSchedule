//
//  SearchablePickerView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 20.03.2025.
//

import SwiftUI

struct SearchablePickerView<T: Identifiable & Equatable, Content: View>: View {
    let title: String
    @Binding var selection: T?
    let items: [T]
    let searchKeyPath: KeyPath<T, String>
    let rowContent: (T) -> Content
    let onSelect: ((T) -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    var filteredItems: [T] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0[keyPath: searchKeyPath].localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack {
            TextField("Поиск...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            List {
                ForEach(filteredItems) { item in
                    Button {
                        selection = item
                        onSelect?(item)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            rowContent(item)
                            Spacer()
                            if selection == item {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                }
            }
        }
    }
}

struct SearchablePickerDemo: View {
    struct ExampleItem: Identifiable, Equatable {
        let id = UUID()
        let name: String
    }

    @State private var selectedItem: ExampleItem?

    let items = [
        ExampleItem(name: "Apple"),
        ExampleItem(name: "Banana"),
        ExampleItem(name: "Cherry"),
        ExampleItem(name: "Дед"),
        ExampleItem(name: "Бабка"),
        ExampleItem(name: "Семен"),
        ExampleItem(name: "411")
    ]

    var body: some View {
        NavigationView {
            VStack {
                Text("Выбрано: \(selectedItem?.name ?? "Ничего")")
                NavigationLink("Выбрать", destination:
                    SearchablePickerView(
                        title: "Выберите фрукт",
                        selection: $selectedItem,
                        items: items,
                        searchKeyPath: \.name
                    ) { item in
                        HStack {
                            Image(systemName: "leaf")
                            Text(item.name)
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    SearchablePickerDemo()
}
