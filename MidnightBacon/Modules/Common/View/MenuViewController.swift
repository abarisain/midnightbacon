//
//  MenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/16/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var menu: MenuDataSource?
    var tableView: UITableView!
    
    override func loadView() {
        tableView = UITableView(frame: CGRect.zeroRect, style: .Grouped)
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu?.numberOfGroups() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu?.numberOfItemsInGroup(section) ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu?.titleForGroup(section) ?? ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = menu?.titleForItemAtIndexPath(indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        menu?.triggerActionForItemAtIndexPath(indexPath)
        
        let shouldHighlight = menu?.shouldHighlightActionAtIndexPath(indexPath) ?? true
        
        if (!shouldHighlight) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}