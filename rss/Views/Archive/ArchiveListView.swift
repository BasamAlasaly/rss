//
//  ArchiveListView.swift
//  rss
//
//  Created by 谷雷雷 on 2020/7/15.
//  Copyright © 2020 acumen. All rights reserved.
//

import SwiftUI

struct ArchiveListView: View {
    
    @ObservedObject var viewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "load more"
    
    init(viewModel: ArchiveListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            List {
                ForEach(self.viewModel.items, id: \.self) { item in
                    RSSItemRow(wrapper: item)
                        .onTapGesture {
                            self.selectedItem = item
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.viewModel.items[index]
                        self.viewModel.unarchive(item)
                    }
                }
                VStack(alignment: .center) {
                    Button(action: self.viewModel.loadMore) {
                        Text(self.footer)
                    }
                }
            }
            .sheet(item: $selectedItem, content: { item in
                if AppEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
                } else {
                    WebView(
                        rssItem: item,
                        onCloseClosure: {
                            
                        },
                        onArchiveClosure: {
                            self.viewModel.archiveOrCancel(item)
                    })
                }
            })
            .onAppear {
                self.viewModel.fecthResults()
            }
        }
    }
}

extension ArchiveListView {
}

struct ArchiveListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
}
