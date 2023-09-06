//
//  Tripify.swift
//  AeroItin
//
//  Created by Matt Zayatz on 9/5/23.
//

import SwiftUI

struct Tripify: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let offset: CGSize
    
    func body(content: Content) -> some View {
        content.frame(
            width: width,
            height: height)
        .offset(offset)
    }
}

extension View {
    func tripify(width: CGFloat, height: CGFloat, offset: CGSize) -> some View {
        modifier(Tripify(width: width, height: height, offset: offset))
    }
}


