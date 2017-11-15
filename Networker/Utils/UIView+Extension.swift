//
//  UIView+Extension.swift
//  Networker
//
//  Created by Big Shark on 20/03/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import Foundation
import UIKit
/*
class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}
*/
extension UILabel {
    func underlineText(){
        guard let text = text else { return }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
    }
}

extension UIImageView{
    
    func setImageWith(color: UIColor)
    {        
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}

extension String {
    func getSubString(count: Int) -> String {        
        let index = self.index(self.startIndex, offsetBy: count)
        return self.substring(to: index)
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        self.init(red: CGFloat(0xFF & (hex >> 16)) / 255.0, green: CGFloat(0xFF & (hex >> 8)) / 255.0, blue: CGFloat(0xFF & hex) / 255.0, alpha: 1)
    }
}


