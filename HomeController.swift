//
//  HomeController.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 26/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import Firebase

class HomeCotroller: UIViewController {
    
    //MARK:- Properties
    
    private var user: User?
    
    private let topStack = HomeNavigationStackView()
    
    private let deckView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 5
        return view
    }()
    
    let bottomStack = BottomControlsStackView()
    
    private var viewModels = [CardViewModel]() {
        didSet { configureCards() }
    }

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        
        configureUI()
        fetchUser()
        fetchUsers()
    }
    
    //MARK:- API
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.fetchUser(withUid: uid) { user in
//            print("DEBUG: Did execute completion in fetchUser() inside homeController..")
            print("DEBUG: User is \(user.name)")
            self.user = user
        }
    }
    
    func fetchUsers() {
        Service.fetchUsers { users in
//            print("DEBUG: Users are:  \(users)")
        
            self.viewModels = users.map({ CardViewModel(user: $0)}) //$0 represents each user in the users array
            // you can do it also in this way:
//            users.forEach { user in
//                let viewModel = CardViewModel(user: user)
//                self.viewModels.append(viewModel)
//            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
//            print("DEBUG: User not logged in..")
            presentLoginController()
        } else {
            print("DEBUG: User is logged in..")
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Signed out and present login controller here..")
            presentLoginController()
        } catch {
            print("DEBUG: Failed to sign out..")
        }
    }
    
    //MARK:- Helpers Functions
    func configureCards(){
//        print("DEBUG: Configure Cards now..")
        viewModels.forEach { (viewModel) in
            let cardView = CardView(viewModel: viewModel)
            deckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        
        topStack.delegate = self
        
        let stack = UIStackView(arrangedSubviews: [topStack, deckView, bottomStack])
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)

        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        stack.bringSubviewToFront(deckView)
    }
    func presentLoginController() {
        DispatchQueue.main.async {
            let controller = LoginController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

}

//MARK:- HomeNavigationStackViewDelegate
extension HomeCotroller: HomeNavigationStackViewDelegate {
    func showSettings() {
        print("DEBUG: Show Settings from home controller..")
        guard let user = self.user else {return}
        //when the user the settings button the "SettingsController" will be initialised with his data
        let controller = SettingsController(user: user)
        controller.delegate = self // activate the SettingsControllerDelegate protocol
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func showMessages() {
        print("DEBUG: Show Messages from home controller..")
    }
    
    
}

//MARK:- SettingsControllerDelegate
extension HomeCotroller: SettingsControllerDelegate {
    func settingsControllerWantsToLogout(_ controller: SettingsController) {
        controller.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: nil, message: "Are you sure you want to logout ?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func settingsController(_ controller: SettingsController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user // passing the user object from the settingsController to the homeController after dismissing
    }
    
    
}
