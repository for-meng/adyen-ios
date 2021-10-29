//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
internal final class DiffableDataSource: UITableViewDiffableDataSource<ListSection, ListItem>, ListViewControllerDataSource {
    internal var cellReuseIdentifier: String { coreDataSource.cellReuseIdentifier }
    
    private typealias DataSnapshot = NSDiffableDataSourceSnapshot<ListSection, ListItem>
    
    internal var sections: [ListSection] {
        get { coreDataSource.sections }
        set { coreDataSource.sections = newValue }
    }
    
    private let coreDataSource = CoreDataSource()
    
    // MARK: - UITableViewDataSource
    
    /// :nodoc:
    override internal func numberOfSections(in tableView: UITableView) -> Int {
        coreDataSource.numberOfSections(in: tableView)
    }
    
    /// :nodoc:
    override internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coreDataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    /// :nodoc:
    override internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        coreDataSource.tableView(tableView, canEditRowAt: indexPath)
    }
    
    /// :nodoc:
    override internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        coreDataSource.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    // MARK: - ListViewControllerDataSource
    
    internal func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        coreDataSource.cell(for: tableView, at: indexPath)
    }

    internal func reload(newSections: [ListSection], tableView: UITableView) {
        sections = newSections.filter { $0.items.isEmpty == false }
        var snapShot = NSDiffableDataSourceSnapshot<ListSection, ListItem>()
        snapShot.appendSections(sections)
        sections.forEach { snapShot.appendItems($0.items, toSection: $0) }
        apply(snapShot, animatingDifferences: true)
        
        if sections.isEditable == false {
            tableView.setEditing(false, animated: true)
        }
    }
    
    internal func deleteItem(at indexPath: IndexPath, tableView: UITableView) {
        var snapshot = snapshot()
        
        deleteItem(at: indexPath, &snapshot)
        
        deleteEmptySections(&snapshot)
        
        apply(snapshot, animatingDifferences: true)
        
        // Disable editing state if no sections are editable any more.
        disableEditingIfNeeded(tableView)
    }
    
    private func deleteItem(at indexPath: IndexPath, _ snapshot: inout DataSnapshot) {
        // Delete the item in sections array.
        let deletedItem = sections[indexPath.section].items[indexPath.item]
        sections[indexPath.section].deleteItem(index: indexPath.item)
        
        // Delete the item in the current NSDiffableDataSourceSnapshot.
        snapshot.deleteItems([deletedItem])
    }
    
    private func deleteEmptySections(_ snapshot: inout DataSnapshot) {
        let sectionsToDelete = sections.filter(\.items.isEmpty)
        sections = sections.filter { $0.items.isEmpty == false }
        snapshot.deleteSections(sectionsToDelete)
    }
    
    private func disableEditingIfNeeded(_ tableView: UITableView) {
        // Disable editing state if no sections are editable any more.
        guard sections.isEditable == false else { return }
        tableView.setEditing(false, animated: true)
    }
    
    // MARK: - Item Loading state
    
    /// Starts a loading animation for a given ListItem.
    ///
    /// - Parameter item: The item to be shown as loading.
    internal func startLoading(for item: ListItem, _ tableView: UITableView) {
        coreDataSource.startLoading(for: item, tableView)
    }
    
    /// Stops all loading animations.
    internal func stopLoading(_ tableView: UITableView) {
        coreDataSource.stopLoading(tableView)
    }
    
}

extension Array where Element == ListSection {
    internal var isEditable: Bool {
        first(where: { $0.header?.editingStyle != EditinStyle.none }) != nil
    }
    
    internal mutating func deleteItem(at indexPath: IndexPath) {
        self[indexPath.section].deleteItem(index: indexPath.item)
        self = self.filter { !$0.items.isEmpty }
    }
}
