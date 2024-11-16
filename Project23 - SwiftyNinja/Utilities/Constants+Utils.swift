//
//  Constants+Utils.swift
//  Project23 - SwiftyNinja
//
//  Created by Noah Pope on 11/8/24.
//

import Foundation

enum ImageKeys
{
    static let sliceBackground  = "sliceBackground"
    static let sliceLife        = "sliceLife"
    static let sliceLifeGone    = "sliceLifeGone"
    static let bomb             = "bomb"
    static let penguin          = "penguin"
    static let speedster        = "speedster"
    static let gameOver         = "gameOver"
}

enum FontKeys
{
    static let chalkduster      = "Chalkduster"
}

enum NameKeys
{
    static let bombContainer    = "bombContainer"    
    static let penguin          = "penguin"
    static let bomb             = "bomb"
    static let speedster        = "speedster"
}

enum SoundKeys
{
    static let launch           = "launch.caf"
    static let sliceBombFuse    =
    "sliceBombFuse.caf"
    static let whack            = "whack.caf"
    static let explosion        = "explosion.caf"
    static let wrong            = "wrong.caf"
}

enum EmitterKeys
{
    static let sliceFuse        = "sliceFuse"
    static let sliceHitEnemy    = "sliceHitEnemy"
    static let sliceHitBomb     = "sliceHitBomb"
}

enum EnemyTypeKeys
{
    static let penguin          = "penguin"
    static let bomb             = "bomb"
    static let speedster        = "speedster"
}
