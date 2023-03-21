//
//  PlaylistAddModal.swift
//  mdxplayer
//
//  Created by Masaaki Taguchi on 2023/03/19.
//  Copyright  asada. All rights reserved.
//

import UIKit
import RealmSwift
import CustomToastView_swift

class PlaylistAddModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView = UITableView()
    var playlistList:Results<Playlist>!
    let realm = try! Realm()
    var token:NotificationToken!
    var selectedTitle:String!
    var selectedFile:String!
    var selectedPath:String!
    var beforeVC:UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        playlistList = realm.objects(Playlist.self).sorted(byKeyPath: "date", ascending: false)
        token = realm.observe{ notification, realm in
            self.tableView.reloadData()
        }

        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        tableView.separatorColor = UIColor(white: 61 / 255, alpha: 1)
        tableView.backgroundColor = UIColor(white: 13 / 255, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44

        self.view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        let navigationBar = UINavigationBar()
        self.tableView.addSubview(navigationBar)

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        if #available(iOS 11.0, *) {
            navigationBar.frame.origin = self.view.safeAreaLayoutGuide.layoutFrame.origin
            navigationBar.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 44)
        }else{
            navigationBar.frame.origin = self.view.frame.origin
            navigationBar.frame.size = CGSize(width: self.view.frame.width, height: 44)
        }

        let navigationItem = UINavigationItem(title: PlaylistConstants.playlistAddModalTitle)
        navigationBar.barStyle = .blackTranslucent
        navigationBar.tintColor = UIColor.mdxColor
        navigationBar.backgroundColor = UIColor(white: 43 / 255, alpha: 1)

        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: nil, action: #selector(createPlaylist))
        navigationItem.rightBarButtonItem = doneBtn
        navigationBar.setItems([navigationItem], animated: false)
    }

    @objc func createPlaylist() {
        showInput(PlaylistConstants.addPlaylistNameTitle,
                  placeholder: PlaylistConstants.addPlaylistNamePlaceholder) {
            let playlistName = $0
            if playlistName.count > 0 {
                PlaylistRealm().create(name:playlistName)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        let count = playlistList.count
        return count
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let playlist = playlistList[indexPath.row]

        let editAction = UITableViewRowAction(style: .destructive, title: PlaylistConstants.editButtonName) { action, index in
            self.showInput(
                PlaylistConstants.renamePlaylistNameTitle,
                placeholder: PlaylistConstants.renamePlaylistNamePlaceholder,
                currentName: playlist.name) {
                let playlistName = $0
                if playlistName.count > 0 {
                    PlaylistRealm().updateName(playlist:playlist, name:playlistName)
                }
            }
            self.tableView.reloadData()
        }
        editAction.backgroundColor = UIColor.mdxColor

        let deleteAction = UITableViewRowAction(style: .destructive, title: PlaylistConstants.deleteButtonName) { action, index in
            self.showOKCancel(
                PlaylistConstants.confirmDeletePreMessage +
                "\(playlist.name)" +
                PlaylistConstants.confirmDeletePostMessage) {
                PlaylistRealm().delete(playlist:playlist)
            }
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = UIColor.red

        return [deleteAction, editAction]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = UIColor(white: 23 / 255, alpha: 1)

        cell.textLabel?.font = UIFont(name: "KH-Dot-Kodenmachou-16-Ki", size: 16) // UIFont.systemFontOfSize(16)
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.textColor = UIColor(red: 174 / 255.0, green: 189 / 255.0, blue: 203 / 255.0, alpha: 1)
        cell.detailTextLabel?.font = .systemFont(ofSize: 12)

        let sv = UIView()
        sv.backgroundColor = UIColor(white: 1, alpha: 0.2)
        cell.selectedBackgroundView = sv
        
        let playlist = playlistList[indexPath.row]
        cell.textLabel?.text = playlist.name

        let formatter = DateFormatter()
        formatter.dateFormat = PlaylistConstants.playlistItemDetailDateFormat
        let formattedDate = formatter.string(from: playlist.date)
        let mdxNumber = playlist.playlistItems.count
        cell.detailTextLabel?.text =
            PlaylistConstants.playlistItemDetailDateTitle + "\(formattedDate)  " +
            PlaylistConstants.playlistItemDetailTotalTitle + "\(mdxNumber)"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = playlistList[indexPath.row]
        PlaylistRealm().addItem(playlist: playlist, title: selectedTitle, path: selectedPath, file: selectedFile)

        self.dismiss(animated: true, completion: {
            Toast.Builder()
                .sideDistance(80)
                .timeDismissal(0.5)
                .toastHeight(50)
                .font(UIFont.systemFont(ofSize: 14, weight: .semibold))
                .backgroundColor(UIColor.mdxColor)
                .textColor(.white)
                .title("Added to \(playlist.name)")
                .orientation(.bottomToTop)
                .textAlignment(.center)
                .build()
                .show(on: UIApplication.shared.windows[0].rootViewController!) { toast in
                    toast.hide()
                }
        })
    }
    
}
