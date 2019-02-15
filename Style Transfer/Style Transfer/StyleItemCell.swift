//
//  StyleItemCell.swift
//  Style Transfer Demo
//
//  Created by taoxiujin on 2019/2/15.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import Foundation
import UIKit

class StyleItemCell: UICollectionViewCell {
    let styleImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 120, height: 148))
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(styleImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
