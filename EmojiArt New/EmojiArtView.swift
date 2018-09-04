//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Liu bo on 31/08/18.
//  Copyright © 2018 Liu bo. All rights reserved.
//

import UIKit

protocol EmojiArtViewDelegate: class {
    func emojiArtDidChange(_ sender: EmojiArtView)
}

extension Notification.Name {
    static let EmojiArtViewChange =
        Notification.Name("EmojiArtViewChange")
}


class EmojiArtView: UIView, UIDropInteractionDelegate {
    
    // MARK: - Delegation
    
    // Using weak avoid memory cycle
    weak var delegate: EmojiArtViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            // Drop location in myself coordinate
            let dropPoint = session.location(in: self)
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
                self.delegate?.emojiArtDidChange(self)
                NotificationCenter.default.post(
                    name: .EmojiArtViewChange,
                    object: self)
            }
        }
    }
    
    private var font: UIFont {
        return
            UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    private var labelObserversions = [UIView:NSKeyValueObservation]()
    
    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint){
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString.font != nil ? attributedString : NSAttributedString(string: attributedString.string,attributes: [.font:self.font])
        
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
        labelObserversions[label] = label.observe(\.center) { (label, change) in
            self.delegate?.emojiArtDidChange(self)
            NotificationCenter.default.post(
                name: .EmojiArtViewChange,
                object: self)
        }
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if labelObserversions[subview] != nil {
            labelObserversions[subview] = nil
        }
        
    }
    
    // MARK: - Drawing the Backgrounf
    
    var backgroundImage: UIImage? { didSet{ setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}










