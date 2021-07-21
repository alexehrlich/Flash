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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetUp()
        
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
        let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
        
        pageControl.currentPage = page
    }
    
    
}


