//
//  FavoriteViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseTableViewController {

    var level: Int = 0
    var content: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    var isLoading = false
    private func loadData() {
        if isLoading {
            print("is loading")
            return
        }
        isLoading = true
        API.Favorite(level: level).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let data = d else {
                print(e?.localizedDescription)
                self?.isLoading = false
                return
            }
            self?.display(Favorite(data: data))
            self?.isLoading = false
        }
    }
    
    private func display(favorite: Favorite) {
        content.removeAll(keepCapacity: false)
        if let subs = favorite.subFavorites {
            content += subs as [AnyObject]
        }
        if let ss = favorite.sections {
            content += ss as [AnyObject]
        }
        if let bs = favorite.boards {
            content += bs as [AnyObject]
        }
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
        case let sub as Favorite:
            cell?.textLabel?.text = sub.desc
            cell?.detailTextLabel?.text = "[目录]"
        case let sec as Section:
            cell?.textLabel?.text = sec.desc ?? sec.name
            cell?.detailTextLabel?.text = "[分区]"
        case let b as Board:
            cell?.textLabel?.text = b.desc ?? b.name
            cell?.detailTextLabel?.text = nil
        default:
            break
        }
        cell?.accessoryType = .DisclosureIndicator
        cell?.detailTextLabel?.textColor = AppSharedInfo.sharedInstance.currentTheme.BoardNaviCellSubtitleColor
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let data = content[indexPath.row]
        switch data {
        case let sub as Favorite:
            if let level = sub.level {
                navigateToFavorite(level)
            }
        case let sec as Section:
            navigateToSectionDetail(sec)
        case let b as Board:
            // FIXME:
            print("to board", b)
        default:
            break
        }
    }
}
