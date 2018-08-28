//
//  StickerPreviewModalController.swift
//  Telegram
//
//  Created by keepcoder on 02/02/2017.
//  Copyright © 2017 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import PostboxMac

fileprivate class StickerPreviewModalView : View {
    fileprivate let imageView:TransformImageView = TransformImageView()
    fileprivate let textView:TextView = TextView()
    required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(imageView)
        addSubview(textView)
        textView.backgroundColor = .clear
        imageView.setFrameSize(100,100)
        self.background = .clear
    }
    
    override func layout() {
        super.layout()
        imageView.center()
        
    }
    
    func update(with reference: FileMediaReference, account:Account) -> Void {
        imageView.setSignal( chatMessageSticker(account: account, fileReference: reference, type: .full, scale: backingScaleFactor), clearInstantly: true, animate:true)
        let size = reference.media.dimensions?.aspectFitted(NSMakeSize(frame.size.width, frame.size.height - 100)) ?? frame.size
        imageView.set(arguments: TransformImageArguments(corners: ImageCorners(), imageSize: size, boundingSize: size, intrinsicInsets: NSEdgeInsets()))
        imageView.frame = NSMakeRect(0, frame.height - size.height, size.width, size.height)
        imageView.layer?.animateScaleSpring(from: 0.5, to: 1.0, duration: 0.2)
        
        let layout = TextViewLayout(.initialize(string: reference.media.stickerText?.fixed, color: nil, font: .normal(30.0)))
        layout.measure(width: .greatestFiniteMagnitude)
        textView.update(layout)
        textView.centerX()
        
        textView.layer?.animateScaleSpring(from: 0.5, to: 1.0, duration: 0.2)
        
        needsLayout = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StickerPreviewModalController: ModalViewController {
    fileprivate let account:Account
    fileprivate var reference:FileMediaReference?
    init(_ account:Account) {
        self.account = account
        
        super.init(frame: NSMakeRect(0, 0, 360, 400))
    }
    
    override var containerBackground: NSColor {
        return .clear
    }
    
    override var handleEvents:Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let reference = reference {
            genericView.update(with: reference, account: account)
        }
        readyOnce()
    }
    
    func update(with reference:FileMediaReference?) {
        if self.reference?.media != reference?.media {
            self.reference = reference
            if isLoaded(), let reference = reference {
                genericView.update(with: reference, account: account)
            }
        }
    }
    
    fileprivate var genericView:StickerPreviewModalView {
        return view as! StickerPreviewModalView
    }
    
    override func viewClass() -> AnyClass {
        return StickerPreviewModalView.self
    }
    
    //    override var isFullScreen: Bool {
    //        return true
    //    }
    
}
