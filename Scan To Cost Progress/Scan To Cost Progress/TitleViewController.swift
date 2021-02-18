//  TitleViewController.swift
//  Scan To Cost Progress
//  Created by Julian on 19.01.21.

import UIKit

class TitleViewController: UIViewController {
    
    @IBOutlet weak var StartButrron: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        assignbackground()
       //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)

        // Do any additional setup after loading the view.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func assignbackground(){
            let background = UIImage(named: "background")

            var imageView : UIImageView!
            imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = background
            imageView.center = view.center
            view.addSubview(imageView)
            self.view.sendSubviewToBack(imageView)
        }
    
    @IBAction func StartAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "action_vc") as! ViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
