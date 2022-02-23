//
//  VIew.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import SwiftUI

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
    
    func addGlowEffect(color1:Color, color2:Color, color3:Color) -> some View {
        self
            .foregroundColor(Color(hue: 0.5, saturation: 0.8, brightness: 1))
            .background {
                self
                    .foregroundColor(color1).blur(radius: 0).brightness(0.8)
            }
            .background {
                self
                    .foregroundColor(color2).blur(radius: 4).brightness(0.35)
            }
            .background {
                self
                    .foregroundColor(color3).blur(radius: 2).brightness(0.35)
            }
            .background {
                self
                    .foregroundColor(color3).blur(radius: 12).brightness(0.35)
                
            }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
            clipShape( RoundedCorner(radius: radius, corners: corners) )
        }
    
    func hasScrollEnabled(_ value: Bool) -> some View {
        self.onAppear {
            UITableView.appearance().isScrollEnabled = value
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
