//
//  Item.swift
//  Todoey
//
//  Created by Sunggon Park on 2024/03/04.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Int = Int(Date().timeIntervalSince1970)
}
