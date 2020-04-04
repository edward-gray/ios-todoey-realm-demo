//
//  SwipeViewController.swift
//  Todoey
//
//  Created by Edward Gray on 04.04.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var customeUIColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        customeUIColor = UIColor.randomFlat()
        view.backgroundColor = customeUIColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Couldn't load naviagtion bar")}
        
        if customeUIColor == nil {
            let contrastHandler = ContrastColorOf(FlatSkyBlue(), returnFlat: true)
            navBar.backgroundColor = FlatSkyBlue()
            navBar.tintColor = contrastHandler
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastHandler]
        } else {
            let contrastHandler = ContrastColorOf(customeUIColor!, returnFlat: true)
            navBar.backgroundColor = customeUIColor
            navBar.tintColor = contrastHandler
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastHandler]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let colour = customeUIColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(getArrayCount())) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        } else {
            cell.backgroundColor = FlatSkyBlue()
            cell.textLabel?.textColor = ContrastColorOf(FlatSkyBlue(), returnFlat: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.onSwipeRightAction(at: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func onSwipeRightAction(at indexPath: IndexPath) {
        // This will get overrided
    }
    
    func getArrayCount() -> Int {
        // This will get overrided
        return 1
    }
    
    func getCustomerColor() -> UIColor {
        return customeUIColor ?? FlatSkyBlue()
    }
}
