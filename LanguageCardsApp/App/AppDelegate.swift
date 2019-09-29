//
//  AppDelegate.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 29/09/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private lazy var wordListAssembly = WordListAssembly()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        window = .init(frame: UIScreen.main.bounds)
        window?.rootViewController = wordListAssembly.assemblyModule()
        window?.makeKeyAndVisible()
        
        return true
    }
}
