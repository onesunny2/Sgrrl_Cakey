//
//  Font+Extensions.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/5/24.
//

import SwiftUI


extension Font {
    static func pilgiFont(size: CGFloat) -> Font {
        return Font.custom("JCfg", size: size)
    }
    
    static func hakgyoFont(size: CGFloat) -> Font {
        return Font.custom("Hakgyoansim Dunggeunmiso OTF B", size: size)
    }
    
    static func gmarketMFont(size: CGFloat) -> Font {
        return Font.custom("GmarketSansMedium", size: size)
    }
    
    static func displayRFont(size: CGFloat) -> Font {
        return Font.custom("SFProDisplay-Regular", size: size)
    }
    
    static func displayMFont(size: CGFloat) -> Font {
        return Font.custom("SFProDisplay-Medium", size: size)
    }
    
    static func displaySMFont(size: CGFloat) -> Font {
        return Font.custom("SFProDisplay-Semibold", size: size)
    }
    
    static var cakeyLargeTitle: Font {
        return pilgiFont(size: 48)
    }
    
    static var cakeyTitle1: Font {
        return gmarketMFont(size: 32)
    }
    
    static var cakeyTitle2: Font {
        return displayRFont(size: 40)
    }

    static var cakeyTitle3: Font {
        return hakgyoFont(size: 30)
    }
    
    static var cakeyHeadline: Font {
        return displaySMFont(size: 24)
    }
    
    static var cakeyBody: Font {
        return displaySMFont(size: 20)
    }
    
    static var cakeyCallout: Font {
        return displayRFont(size: 17)
    }
    
    static var cakeySubhead: Font {
        return displaySMFont(size: 14)
    }
    
    static var cakeyCaption1: Font {
        return displayRFont(size: 14)
    }
}

