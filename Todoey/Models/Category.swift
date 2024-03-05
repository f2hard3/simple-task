//
//  Category.swift
//  Todoey
//
//  Created by Sunggon Park on 2024/03/04.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var color: String = ""
    @Persisted var items: List<Item>
}
