//
//  UITextViewExtension.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

extension UITextView {
  func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    let attributedOriginalText = NSMutableAttributedString(string: originalText)
    
    for (hyperLink, urlString) in hyperLinks {
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Chalkduster", size: 20) as Any, range: fullRange)
    }

    linkTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
    ]
    attributedText = attributedOriginalText
  }
}
