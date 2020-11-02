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
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let bottomStack = BottomControlsStackView()
    
    private var viewModels = [CardViewModel]() {
        didSet { configureCards() }
    }
    
    private var topCardView: CardView?
    private var cardViews = [CardView]()

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        configureUI()
        fetchCurrentUserAndCards()
    }
    
    //MARK:- API
    
    func fetchCurrentUserAndCards() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.fetchUser(withUid: uid) { user in
//            print("DEBUG: Did execute completion in fetchUser() inside homeController..")
//            print("DEBUG: User is \(user.name)")
            self.user = user
            self.fetchUsers(forCurrentUser: user)
        }
    }
    
    func fetchUsers(forCurrentUser user: User) {
        Service.fetchUsers (forCurrentUser: user) { users in
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
            cardView.delegate = self // to activate the CardViewDelegate protocol
            deckView.addSubview(cardView)
            cardView.fillSuperview()
//            cardViews.append(cardView) // or n11
        }
        // taking all the subviews in the deckView and puting theme in the cardViews array
        /*n11*/ cardViews = deckView.subviews.map({ ($0 as? CardView)! })
        
        topCardView = cardViews.last
    }
    func configureUI() {
        view.backgroundColor = .white
        
        topStack.delegate = self
        
        let stack = UIStackView(arrangedSubviews: [topStack, deckView, bottomStack])
        stack.axis = .vertical
        bottomStack.delegate =  self // activate the BottomControlsStackViewDelegate protocol
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
            controller.delegate = self //activate the AuthenticationDelegate controller
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func performSwipeAnimation(shouldLike: Bool) {
        
        let translation: CGFloat = shouldLike ? 700 : -700
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            self.topCardView?.frame = CGRect(x: translation, y: 0,
                                             width: (self.topCardView?.frame.width)!,
                                             height:(self.topCardView?.frame.height)!)
            
        }) { _ in
            self.topCardView?.removeFromSuperview()
            guard !self.cardViews.isEmpty else {return}
            self.cardViews.remove(at: self.cardViews.count - 1)
            self.topCardView = self.cardViews.last
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

//MARK:- CardViewDelegate
extension HomeCotroller: CardViewDelegate {
    func cardView(_ view: CardView, didLikeUser: Bool) {
        view.removeFromSuperview() //remove the swiped Card from the view
        self.cardViews.removeAll(where: { view == $0 }) //update the dataModel (cardViews : array that contains all the users cards)
        
        guard let user = topCardView?.viewModel.user else {return}
        Service.saveSwipe(forUser: user, isLike: didLikeUser)
    
        self.topCardView = cardViews.last
    }
    
    func cardView(_ view: CardView, wantsToShowProfileFor user: User) {
        let controller = ProfileController(user: user) //passing the user that we have get it from the cardView to the profileController
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    
}

//MARK:- BottomControlsStackViewDelegate
extension HomeCotroller: BottomControlsStackViewDelegate {
    func handleLike() {
//        print("DEBUG: Handle liking here..")
        guard let topCard = topCardView else {return}
        
        Service.saveSwipe(forUser: topCard.viewModel.user, isLike: true)

        //if there is no topView the bellow func will not be called
        performSwipeAnimation(shouldLike: true)
//        print("DEBUG: Liked user is \(topCard.viewModel.user.name)")
    }
    
    func handleDislike() {
        
        guard let topCard = topCardView else {return}

        print("DEBUG: Handle disliking here..")
        performSwipeAnimation(shouldLike: false)
                
        Service.saveSwipe(forUser: topCard.viewModel.user, isLike: false)

    }
    
    func handleRefresh() {
        print("DEBUG: Handle refreshing here..")
    }
    
    
}

//MARK:- extension HomeCotroller: ProfileControllerDelegate {

extension HomeCotroller: ProfileControllerDelegate {
    func profileController(_ controller: ProfileController, didLikeUser user: User) {
        print("DEBUG: Handle liking user in home controller..")
        controller.dismiss(animated: true) { // it will not performe the swipe animation func until the dismissal animation had completed
            self.performSwipeAnimation(shouldLike: true)
            Service.saveSwipe(forUser: user, isLike: true)
        }
    }
    
    func profileController(_ controller: ProfileController, didDislikeUser user: User) {
        print("DEBUG: Handle disliking user in home controller..")
        controller.dismiss(animated: true) {
            self.performSwipeAnimation(shouldLike: false)
            Service.saveSwipe(forUser: user, isLike: false)
        }
        
    }
    
    
}

//MARK:- AuthenticationDelegate

//using the AuthenticationDelegate protocol to resolve the issue of refreshing the views with the new logged in user

//refetching the user and set it again
extension HomeCotroller: AuthenticationDelegate {
    func authenticationComplete() {
        self.dismiss(animated: true, completion: nil) //dismiss the loginController to show the homeController (initialy the root controller is the home one but while the user is not logged in we push the loginController to be on the top of the homeController so when we dismiss it out we will be able to show our main interface "homeController" again)
        fetchCurrentUserAndCards()
    }
    
    
}

