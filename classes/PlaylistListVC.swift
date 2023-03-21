//
//  PlaylistListVC.swift
//  mdxplayer
//
//  Created by Masaaki Taguchi on 2023/03/19.
//  Copyright  asada. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistListVC: ListVC {
    var playlistList:Results<Playlist>!
    let realm = try! Realm()
    var token:NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        showRightButton()
    }

    func showRightButton() {
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(createPlaylist))
        navigationItem.rightBarButtonItem = doneBtn
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

    override func reload() {
        playlistList = realm.objects(Playlist.self).sorted(byKeyPath: "date", ascending: false)
        token = realm.observe{ notification, realm in
            self.tableView.reloadData()
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return playlistList.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row >= playlistList.count { return cell }

        let playlist = playlistList[indexPath.row]
        cell.textLabel?.text = playlist.name
        let formatter = DateFormatter()
        formatter.dateFormat = PlaylistConstants.playlistItemDetailDateFormat
        let formattedDate = formatter.string(from: playlist.date)
        let mdxNumber = playlist.playlistItems.count
        cell.detailTextLabel?.text =
            PlaylistConstants.playlistItemDetailDateTitle + "\(formattedDate)  " +
            PlaylistConstants.playlistItemDetailTotalTitle + "\(mdxNumber)"
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let playlist = playlistList[indexPath.row]
        var vc: PlaylistItemListVC!
        vc = PlaylistItemListVC()
        vc.playlist = playlist
        navigationController?.pushViewController(vc, animated: true)
    }

}
