//
//  SectionViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class SectionViewController: BaseTableViewController {

    var section: Section?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = section?.desc
        tableView.tableFooterView = UIView()
        loadData()
    }
    
    var isLoading = false
    private func loadData() {
        if isLoading {
            po("isloading or section is nil")
            return
        }
        isLoading = true
        guard let section = self.section else {
            API.Sections.handleResponse({ [weak self] (_, _, data, error) -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isLoading = false
                guard let data = data else {
                    // TODO: -
                    po(error?.localizedDescription)
                    return
                }
                strongSelf.content = Section.generateArray(data["section"])
                strongSelf.tableView.reloadData()
            })
            return
        }
        guard let name = section.name else {
            po("name is nil of section", section)
            isLoading = false
            return
        }
        API.Section(name: name).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let data = d else {
                po(e!.localizedDescription)
                self?.isLoading = false
                return
            }
            self?.section = Section(data: data)
            self?.isLoading = false
            self?.display()
        }
    }
    
    var content: [AnyObject] = []
    private func display() {
        content.removeAll(keepCapacity: false)
        if let sections = section?.subSections {
            content += sections as [AnyObject]
        }
        if let boards = section?.boards {
            content += boards as [AnyObject]
        }
        self.title = section?.desc
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    let cellID = "cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellID)
        }
        let data = content[indexPath.row]
        switch data {
        case let s as Section:
            cell?.textLabel?.text = s.desc ?? s.name
            cell?.detailTextLabel?.text = "[分区]"
        case let b as Board:
            cell?.textLabel?.text = b.desc ?? b.name
            cell?.detailTextLabel?.text = nil
        default:
            break
        }
        cell?.detailTextLabel?.textColor = AppSharedInfo.sharedInstance.currentTheme.BoardNaviCellSubtitleColor
        cell?.accessoryType = .DisclosureIndicator
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let data = content[indexPath.row]
        switch data {
        case let s as Section:
            navigateToSectionDetail(s)
        case let b as Board:
            if let name = b.name {
                navigateToBoard(name)
            }
            break
        default:
            break
        }
    }
}
