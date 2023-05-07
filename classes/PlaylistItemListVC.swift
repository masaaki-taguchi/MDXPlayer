//
//  PlaylistDetailListVC.swift
//  mdxplayer
//
//  Created by Masaaki Taguchi on 2023/03/19.
//  Copyright  asada. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistItemListVC: ListVC {
    var playlist:Playlist!

    let realm = try! Realm()
    var token:NotificationToken!
    var editMode = false
    var shuffleButtonView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        showRightButton()
        navigationItem.title = playlist.name
    }

    override func reload() {
    }

    func showRightButton() {
        let editButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit"), style: .plain, target: self, action: #selector(editPlaylist))
        let shuffleButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "shuffle"), style: .plain, target: self, action: #selector(shuffle))
        navigationItem.rightBarButtonItems = [editButton, shuffleButton]
    }

    @objc func editPlaylist() {
        editMode = !editMode
        tableView.isEditing = editMode
    }

    func existCheckPlayFile(playlist:Playlist, playFiles:[String]) -> [String] {
        var cnt: Int = 0
        var deleteFileIndexList: [Int] = []
        var checkedPlayFiles: [String] = []
        let fileMgr = FileManager.default
        for playfile in playFiles {
            if fileMgr.fileExists(atPath: playfile) {
                checkedPlayFiles.append(playfile)
            } else {
                deleteFileIndexList.append(cnt)
            }
            cnt += 1
        }
        if (deleteFileIndexList.count > 0) {
            PlaylistRealm().deleteItems(playlist: self.playlist, deleteItemIndexList: deleteFileIndexList)
        }
        return checkedPlayFiles
    }
    
    @objc func shuffle() {
        PlaylistRealm().updateDate(playlist: self.playlist)

        var playFiles: [String] = []
        let selected: Int = 0
        for playlistItem in playlist.playlistItems {
            let localFullPath = ListVC.path2local(playlistItem.path) + "/" + playlistItem.file
            playFiles.append(localFullPath)
        }
        var checkedPlayFiles = existCheckPlayFile(playlist: self.playlist, playFiles: playFiles)

        let count = checkedPlayFiles.count
        for i in stride(from: count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            if i != j {
                checkedPlayFiles.swapAt(i, j)
            }
        }
        
        Player.sharedInstance().playFiles(checkedPlayFiles, index: selected)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: PlaylistConstants.deleteButtonName) { action, index in
            PlaylistRealm().deleteItem(playlist: self.playlist, itemIndex: indexPath.row)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        PlaylistRealm().replaceOrderItem(playlist: self.playlist, sourceItemIndex: sourceIndexPath.row, destinationItemIndex:destinationIndexPath.row)
        self.tableView.reloadData()
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return playlist.playlistItems.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.row >= playlist.playlistItems.count { return cell }
        let playlistItem = playlist.playlistItems[indexPath.row]

        cell.textLabel?.text = playlistItem.title
        cell.detailTextLabel?.text = "\(playlistItem.path)/\(playlistItem.file)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        PlaylistRealm().updateDate(playlist: self.playlist)
        var playFiles: [String] = []
        let selected: Int = indexPath.row
        for playlistItem in playlist.playlistItems {
            let localFullPath = ListVC.path2local(playlistItem.path) + "/" + playlistItem.file
            playFiles.append(localFullPath)
        }
        let checkedPlayFiles = existCheckPlayFile(playlist: self.playlist, playFiles: playFiles)
                
        Player.sharedInstance().playFiles(checkedPlayFiles, index: selected)
    }

}

