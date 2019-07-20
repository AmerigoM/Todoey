//
//  Item.swift
//  Todoey
//
//  Created by Amerigo Mancino on 19/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    /* fromType: category of the parent, obtained by putting .self after the class name
     * property: the object defined in the parent class for the one to many relationship */
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
