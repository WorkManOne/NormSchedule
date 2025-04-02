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
    let onSelect: ((T) -> Void)?
    let onDelete: ((IndexSet) -> Void)?
    let rowContent: (T) -> Content

    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    init(title: String,
         selection: Binding<T?>,
         items: [T],
         searchKeyPath: KeyPath<T, String>,
         onSelect: ((T) -> Void)? = nil,
         onDelete: ((IndexSet) -> Void)? = nil,
         @ViewBuilder rowContent: @escaping (T) -> Content
         ) {
        self.title = title
        self._selection = selection
        self.items = items
        self.searchKeyPath = searchKeyPath
        self.rowContent = rowContent
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

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
                .if(onDelete != nil) { view in
                    view.onDelete(perform: onDelete!)
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

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
