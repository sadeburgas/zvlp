//
//  HomeVC.swift
//  ZVLP
//
//  Created by sade on 10/03/2019.
//  Copyright © 2019 sade. All rights reserved.
//

import UIKit
import RevealingSplashView

class MainVC: UIViewController {
    
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()

        revealingSplashView.heartAttack = true
        
    }


}

