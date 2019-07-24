//
//  Category.swift
//  Todoey
//
//  Created by Amerigo Mancino on 19/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    // properties
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    // relationships
    let items = List<Item>()
}
