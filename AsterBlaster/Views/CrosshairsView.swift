//
//  CrosshairsView.swift
//  AsterBlaster
//
//  Created by Eddie Char on 11/2/20.
//

import UIKit

class CrosshairsView: UIView {
    init(frame: CGRect, with color: UIColor) {
        super.init(frame: frame)

        let verticalLine = UIView(frame: CGRect(x: frame.width / 2 - 1, y: 0, width: 2, height: frame.height))
        let horizontalLine = UIView(frame: CGRect(x: 0, y: frame.height / 2 - 1, width: frame.width, height: 2))

        verticalLine.backgroundColor = color
        horizontalLine.backgroundColor = color
        
        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
