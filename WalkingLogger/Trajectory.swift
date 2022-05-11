//
//  Trajectory.swift
//  WalkingLogger
//
//  Created by SASAKI, Iori on 2022/05/11.
//

import Foundation

struct Trajectory: Codable {
    // メタデータ(データ本体に対する付帯情報 → データを効率的に管理したり検索したりする上で有用)
    var createdAt: String   // 作成日時
    var age: Int    // 記録者の年齢
    var device: String  //記録に用いたデバイス
    var description: String     // コメントやメモ
    
    // データ本体(一定時間ごとに取得された位置データのリスト)
    // 「緯度、経度、タイムスタンプ」の配列
    var locationList: [LocationData]
    
    // イニシャライザ
    init(age: Int, device: String, description: String) {
        self.age = age
        self.device = device
        self.description = description
        self.createdAt = Tools.generateStringTimestamp()
        self.locationList = []
    }
    
    // コンピューテッドプロパティ
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}

struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var timestamp: String
}

