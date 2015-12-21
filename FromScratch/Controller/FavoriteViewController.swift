//
//  FavoriteViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseTableViewController {

    var level: Int?
    
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
        guard let level = level else {
            print("level is nil")
            return
        }
        isLoading = true
        API.Favorite(level: level).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let data = d else {
                print(e?.localizedDescription)
                self?.isLoading = false
                return
            }
            
            self?.isLoading = false
        }
    }
}
