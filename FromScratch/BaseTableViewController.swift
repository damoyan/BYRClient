//
//  BaseTableViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/30/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        request(RequestGenerator.Default).responseJSON { res -> () in
            if let e = res.result.error {
                print(e)
            }
            print(JSON(res.result.value!))
        }
    }
}
