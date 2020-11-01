//
//  SettingsController.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 30/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol SettingsControllerDelegate: class {
    func settingsController(_ controller: SettingsController, wantsToUpdate user: User)
    func settingsControllerWantsToLogout(_ controller: SettingsController)

}
class SettingsController: UITableViewController {
    
    //MARK:- Properties
    
    private var user: User
    
    private lazy var headerView = SettingsHeader(user: user) //we use "lazy var" because we can't use a simple "let" or "var" with a level class properties outside of initialisers or functions
    private let footerView = SettingsFooter()
    private let imagePicker = UIImagePickerController()
    private var imageIndex = 0
    
    weak var delegate: SettingsControllerDelegate?
    
    //MARK:- LifeCycle
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    
    }
    
    //MARK:- Actions (Selectors)
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        print("DEBUG: Handle did tap done..")
        view.endEditing(true)
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Your Data.."
        hud.show(in: view)
        
        Service.saveUserData(user: user) { err in
            self.delegate?.settingsController(self, wantsToUpdate: self.user)
        }
    }
    
    //MARK:- API
    
    func uploadImage(image: UIImage) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Image.."
        hud.show(in: view)
        
        Service.uploadImage(image: image) { imageUrl in
            self.user.imageURLs.append(imageUrl)
            print("DEBUG: User image URLs:  \(self.user.imageURLs)")
            hud.dismiss()
        }
    }
    
    //MARK:- Helpers
    
    func setHeaderImage(_ image: UIImage?) {
        
        headerView.buttons[imageIndex].setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func configureUI() {
        
        headerView.delegate = self
        imagePicker.delegate = self
        
        navigationItem.title = SETTINGS
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))

        tableView.separatorStyle = .none
        
        tableView.backgroundColor = .systemGroupedBackground
//        tableView.rowHeight = 44 // set the row height universaly : same height for every row
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        
        //register our custom cell in our tableView
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SETTINGS_CELL)
        
        tableView.tableFooterView = footerView
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 88)
        footerView.delegate = self

    }
}

//MARK:- SettingsHeaderDelegate
extension SettingsController: SettingsHeaderDelegate {
    func settingsHeader(_ header: SettingsHeader, didSelect index: Int) {
//        print("DEBUG: Selected photo is : \(index)")
        self.imageIndex = index
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "TinderLikeApp", message: "Select the pic source", preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                print("DEBUG: Unavailable cam in the simulator")
            }
            
        }
        
        let library = UIAlertAction(title: "Choose an Image from your photoLibrary", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                print("DEBUG: Unavailable")
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
//        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

//MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedSelectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
         uploadImage(image: editedSelectedImage)
         setHeaderImage(editedSelectedImage)
        }
        
        // removed to avoid the twice upload of the image
//        if let originalSelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            uploadImage(image: originalSelectedImage)
//            setHeaderImage(originalSelectedImage)
//        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDataSource
extension SettingsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL, for: indexPath) as! SettingsCell
        guard let section = SettingsSections(rawValue: indexPath.section) else {return cell}
        let viewModel = SettingsViewModel(user: user, section: section)
        cell.viewModel = viewModel
        cell.delegate = self // to activate the SettingsCellDelegate protocol
        return cell
    }
}

//MARK:- UITableViewDelegate
extension SettingsController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = SettingsSections(rawValue: section) else {return nil}
        return section.description
    }

    //set dynamically the height for each row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SettingsSections(rawValue: indexPath.section) else {return 0}
        return section == .ageRange ? 96 : 44
    }
}

//MARK:- SettingsCellDelegate
extension SettingsController: SettingsCellDelegate {
    
    func settingsCell(_ cell: SettingsCell, wantsToUpdateAgeRangeWith sender: UISlider) {
//        print("DEBUG: Update age preferences here..")
        if sender == cell.minAgeSlider {
            user.minSeekingAge = Int(sender.value)
        } else {
            user.maxSeekingAge = Int(sender.value)
        }
    }
    
    func settingsCell(_ cell: SettingsCell, wantsToUpdateUserWith value: String, for section: SettingsSections) {
        
        switch section {
        case .name: user.name = value
        case .profession:  user.profession = value
        case .age: user.age = Int(value) ?? user.age
        case .bio: user.bio = value
        case .ageRange: break
        }
        
        print("DEBUG: User is \(user)")
    }
    
}


//MARK:- SettingsFooterDelegate

extension SettingsController: SettingsFooterDelegate {
    func handleLogout() {
        delegate?.settingsControllerWantsToLogout(self)
    }
}


//delegate the logout func from the footerView to the settingsController, then from the settingsController to the homeController
