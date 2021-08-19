//
//  ViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 08.07.21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var pageOneView: PageOneView!
    @IBOutlet weak var pageTwoView: PageTwoView!
    @IBOutlet weak var pageThreeView: PageThreeView!
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        pageControl.currentPage = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetUp()
        self.title = "Flash⚡️"
        
        scrollView.delegate = self
        scrollView.layer.cornerRadius = scrollView.frame.width * 0.08
    }

    private func UISetUp(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named: "TitleColorBlue")!]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }

}

extension WelcomeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x/scrollView.frame.width
        pageControl.currentPage = Int(page)
        
        switch page{
        
        case 0.0 : pageThreeView.animate = false; pageTwoView.animtate = false
        case 1.0 : pageThreeView.animate = false; pageTwoView.animtate = true
        case 2.0 : pageThreeView.animate = true; pageTwoView.animtate = false
            
        default: pageThreeView.animate = false; pageTwoView.animtate = false
        }

    }
    
    
}


