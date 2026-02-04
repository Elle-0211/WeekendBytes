//
//  DataModels.swift
//  Weekend
//
//  Created by STUDENT on 8/29/25.
//


import Foundation


// MARK: - Data Models
// A model to represent a menu item.
struct Item: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let image: String
}

// A model to represent a promo.
struct Promo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String
}

// A model to represent a user's address.
struct Address: Identifiable {
    var id: String
    var label: String
    var street: String
    var city: String
    
}

// A model to represent a user's past order.
struct Order: Identifiable {
    var id: String
    var date: String
    var items: [String: Int]
    var total: Double
}

// MARK: - Sample Data
let newItems = [
    Item(name: "Classic Hamburger", description: "Juicy beef patty with cheese and fresh veggies.", price: 40.0, image: "ClassicBurger"),
    Item(name: "Lasagna", description: "Meaty sauce, topped with white sauce & melted mozzarella cheese..", price: 120.0, image: "lasagna"),
    Item(name: "Nachos", description: "Crispy chips with cheesy goodness.", price: 80.0, image: "nachos"),
    Item(name: "Milkshake", description: "Hotdog with a generous amount of melted cheese.", price: 75.0, image: "Milkshake")
]

let promos = [
    Promo(name: "TGIF!", description: "Hotodgs and Burgers are 20% off!", image: "Promo1"),
    Promo(name: "Saturday Saver", description: "Buy two Burgers or Hotdogs and get 1 any fries free!", image: "Promo2"),
    Promo(name: "Sunday Feast", description: "All menu items are 50% off!", image: "Promo3"),
]

let menuItems: [String: [Item]] = [
    "Hotdogs": [
        Item(name: "Classic Byte", description: "Classic hotdog on a bun with ketchup and mustard.", price: 35.0, image: "ClassicDog"),
        Item(name: "Cheesy Byte", description: "Hotdog with a generous amount of melted cheese.", price: 45.0, image: "cheesedog"),
        Item(name: "Bacon- Wrapped Byte", description: "Savory hotdog wrapped in crispy bacon.", price: 45.0, image: "baconHotdog"),
        Item(name: "Spicy Byte", description: "Kick of jalapeños and spicy mayo for spicy lovers.", price: 65.0, image: "chilidog"),
        Item(name: "Loaded Byte", description: "Topped with chili, cheese, and onions for the ultimate bite!", price: 70.0, image: "LoadedDog")
    ],
    "Fries": [
        Item(name: "Classic Fries", description: "Crispy and golden brown, lightly salted.", price: 30.0, image: "ClassicFries"),
        Item(name: "Cheesy Fries", description: "Fries topped with rich melted cheese sauce.", price: 40.0, image: "cheeseFries"),
        Item(name: "Chili Fries", description: "Fries topped with chili sauce.", price: 50.0, image: "chili_fries"),
        Item(name: "Bacon Cheese Fries", description: "Fries topped with bacon bits & melted cheese sauce.", price: 70.0, image: "baconFries"),
        Item(name: "BBQ Fries", description: "Tossed in smoky barbecue seasoning.", price: 40.0, image: "bbqFries")
    ],
    "Burger": [
        Item(name: "Classic Burger", description: "A single patty with melted cheddar.", price: 40.0, image: "ClassicBurger"),
        Item(name: "Double Stack Burger", description: "A double patty with melted cheddar.", price: 60.0, image: "Burger2"),
        Item(name: "BBQ Burger", description: "Smoked bbq sauce, onion rings and cheddar.", price: 80.0, image: "Burger3"),
        Item(name: "Mushroom Swiss Burger", description: "Sautéed mushrooms, Swiss cheese, and caramelized onions.", price: 120.0, image: "Burger4"),
        Item(name: "Spciy Jalapeno Burger", description: "Zesty jalapeños and spicy sauce to kick it up.", price: 110.0, image: "spicyBurger"),
    ],
    "Limited": [
        Item(name: "Lasagna", description: "Meaty sauce, topped with white sauce & melted mozzarella cheese.", price: 120.0, image: "lasagna"),
        Item(name: "Nachos", description: "Crispy chips with cheesy goodness.", price: 80.0, image: "nachos"),
        Item(name: "Milkshake", description: "A blend milk and chocolate topped with whipped cream and syrup.", price: 75.0, image: "Milkshake"),
    ],
    "Drinks": [
        Item(name: "Soda", description: "A refreshing bottle of Coke.", price: 30.0, image: "soda"),
        Item(name: "Iced Tea", description: "Freshly brewed iced tea.", price: 45.0, image: "icedtea"),
        Item(name: "Lemonade", description: "A classic, tangy lemonade.", price: 45.0, image: "lemon"),
        Item(name: "Berry Fizz", description: "A fizzy berry fizz.", price: 50.0, image: "BerrySoda"),
        Item(name: "Choco Float", description: "A chocolate float topped with whipped cream.", price: 45.0, image: "chocofloat")
    ]
]

/*let sampleAddresses: [Address] = [
    Address(label: "Home", street: "123 Purok 1, Lucena", city: "Lucena City"),
    Address(label: "Work", street: "456 Main St, Quezon", city: "Quezon City")
]

let sampleOrders: [Order] = [
    Order(date: "Aug 28, 2025", items: ["Classic Hamburger": 1, "Classic Fries": 1], total: 180.0),
    Order(date: "Aug 25, 2025", items: ["Cheesy Hotdog": 2, "Soda": 2], total: 270.0),
    Order(date: "Aug 20, 2025", items: ["BBQ Burger": 1, "Iced Tea": 1], total: 135.0)
]*/
