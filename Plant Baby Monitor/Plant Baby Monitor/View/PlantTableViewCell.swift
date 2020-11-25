//
//  PlantTableViewCell.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 24/10/20.
//

import UIKit

class PlantTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantLocation: UILabel!
    @IBOutlet weak var frameViewCorner: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // add border and color
        self.backgroundColor = UIColor.systemBackground
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = frameViewCorner.frame.size.height / 10
        self.clipsToBounds = true
        
        frameViewCorner.layer.cornerRadius = frameViewCorner.frame.size.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}
