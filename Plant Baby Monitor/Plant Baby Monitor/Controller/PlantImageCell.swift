//
//  PlantImageCell.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 21/11/20.
//

import UIKit

class PlantImageCell: UICollectionViewCell {
    static var identifier: String = K.Identifier.plantImageCell
    
    
    @IBOutlet weak var plantCellImageView: UIImageView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    /// to make sure that the cell is not selected randomly: Keeping the cell status
    override var isSelected: Bool{
        willSet{
            super.isSelected = newValue
            if newValue
            {
                self.layer.borderWidth = 4.0
                self.layer.cornerRadius = 10
                self.layer.borderColor = UIColor.systemGreen.cgColor
            }
            else
            {
                self.layer.cornerRadius = 10
                self.layer.borderWidth = 1.0
                self.layer.borderColor = UIColor.systemGroupedBackground.cgColor
            }
        }
    }
}
