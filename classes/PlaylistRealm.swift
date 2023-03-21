//
//  PlaylistRealm.swift
//  mdxplayer
//
//  Created by Masaaki Taguchi on 2023/03/19.
//  Copyright  asada. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var date = Date()

    let playlistItems = List<PlaylistItem>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

class PlaylistItem: Object {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var path = ""
    @objc dynamic var file = ""
    @objc dynamic var order = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

class PlaylistRealm {
    let realm = try! Realm()
    
    func create(name:String) {
        let playlist = Playlist()
        playlist.id = UUID().uuidString
        playlist.name = name
        try! realm.write {
            realm.add(playlist)
        }
    }
        
    func addItem(playlist:Playlist, title:String, path:String, file:String) {
        let order = playlist.playlistItems.count
        let playlistItem = PlaylistItem()
        playlistItem.id = UUID().uuidString
        playlistItem.title = title
        playlistItem.path = path
        playlistItem.file = file
        playlistItem.order = order
        try! realm.write {
            playlist.playlistItems.append(playlistItem)
        }
    }

    func deleteItem(playlist:Playlist, itemIndex:Int) {
        realm.beginWrite()

        let playlistItem = playlist.playlistItems[itemIndex]
        playlist.playlistItems.remove(at: itemIndex)
        realm.delete(playlistItem)

        var cnt = 0
        for playlistItem in playlist.playlistItems {
            playlistItem.order = cnt
            cnt = cnt + 1
        }

        try! realm.commitWrite()
    }

    func deleteItems(playlist:Playlist, deleteItemIndexList:[Int]) {
        realm.beginWrite()
        var deleteCnt:Int = 0
        for itemIndex in deleteItemIndexList {
            let playlistItem = playlist.playlistItems[itemIndex + deleteCnt]
            playlist.playlistItems.remove(at: itemIndex + deleteCnt)
            realm.delete(playlistItem)
            deleteCnt += 1
        }
        
        var cnt = 0
        for playlistItem in playlist.playlistItems {
            playlistItem.order = cnt
            cnt += 1
        }

        try! realm.commitWrite()
    }

    func replaceOrderItem(playlist:Playlist, sourceItemIndex:Int, destinationItemIndex:Int) {
        realm.beginWrite()

        var tempPlaylistItems = Array<PlaylistItem>()
        for playlist in playlist.playlistItems {
            tempPlaylistItems.append(playlist)
        }
        let sourcePlaylistItem = playlist.playlistItems[sourceItemIndex]

        tempPlaylistItems.remove(at: sourceItemIndex)
        tempPlaylistItems.insert(sourcePlaylistItem, at:destinationItemIndex)
        var cnt = 0
        for playFile in tempPlaylistItems {
            playlist.playlistItems[cnt] = playFile
            cnt += 1
        }

        cnt = 0
        for playlistItem in playlist.playlistItems {
            playlistItem.order = cnt
            cnt += 1
        }

        try! realm.commitWrite()
    }

    func updateName(playlist:Playlist, name:String) {
        realm.beginWrite()
        playlist.name = name
        try! realm.commitWrite()
    }

    func updateDate(playlist:Playlist) {
        realm.beginWrite()
        playlist.date = Date()
        try! realm.commitWrite()
    }

    func delete(playlist:Playlist) {
        realm.beginWrite()
        for playlistItem in playlist.playlistItems {
            realm.delete(playlistItem)
        }
        realm.delete(playlist)
        try! realm.commitWrite()
    }

    
}
