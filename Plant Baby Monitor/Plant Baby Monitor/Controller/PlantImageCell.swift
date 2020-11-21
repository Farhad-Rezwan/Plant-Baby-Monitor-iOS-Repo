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
    
    /// to make sure that the cell is not selected randomly
    override var isSelected: Bool{
        willSet{
            super.isSelected = newValue
            if newValue
            {
                self.layer.borderWidth = 1.0
                self.layer.cornerRadius = self.bounds.height / 2
                self.layer.borderColor = UIColor.gray.cgColor
            }
            else
            {
                self.layer.borderWidth = 0.0
                self.layer.cornerRadius = 0.0
            }
        }
    }
}
