//
//  File.swift
//  
//
//  Created by Gabriel Motelevicz Okura on 16/04/23.
//

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let alienBullet  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let playerBullet = CollisionCategory(rawValue: 1 << 1)
    static let alien = CollisionCategory(rawValue: 1 << 2) // 00..10
    static let player = CollisionCategory(rawValue: 1 << 3)
    static let limit = CollisionCategory(rawValue: 1 << 4)
}

struct SceneCollisionCategory {
    static let alienBullet: UInt32  = 0x1 << 1
    static let playerBullet: UInt32 = 0x1 << 2
    static let alien: UInt32 = 0x1 << 3 //
    static let player: UInt32 = 0x1 << 4
    static let limit: UInt32 = 0x1 << 5
}
