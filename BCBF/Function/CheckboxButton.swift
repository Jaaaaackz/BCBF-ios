//
//  CheckboxButton.swift
//  BCBF
//
//  Created by user216835 on 4/20/22.
//  Source:https://www.youtube.com/watch?v=R8SGEQXxhWw

import UIKit

class CheckboxButton: UIView {

    var isChecked=false
    
    let imageView:UIImageView={
        let imageView=UIImageView()
        imageView.isHidden=true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.image=UIImage(systemName:"checkmark")
        return imageView
    }()
    
    let boxView:UIView = {
        let view=UIView()
        view.layer.borderWidth=1
        view.layer.borderColor=UIColor.label.cgColor
        return view
    }()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        backgroundColor = nil
        addSubview(boxView)
        addSubview(imageView)
        clipsToBounds=true
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        boxView.frame=CGRect(x: 8, y: 8, width: frame.size.width-16, height: frame.size.width-16)
        imageView.frame=bounds
    }

    public func toggle(){
        self.isChecked = !isChecked
        imageView.isHidden = !isChecked
    }
    
    public func getIsCheck()->Bool{
        return isChecked
    }
}
