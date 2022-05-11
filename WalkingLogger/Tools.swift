//
//  Tools.swift
//  WalkingLogger
//
//  Created by SASAKI, Iori on 2022/05/11.
//

import Foundation

struct Tools {
    
    // タイプメソッド(staticメソッド)：いちいちインスタンス化しなくても使えるメソッド(いつでも同様の処理を呼び出すことができる)
    // return: yyyyMMddTHHmmssZ
    static func generateStringTimestamp() -> String {
        let now = Date()
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.remove([.withDashSeparatorInDate, .withColonSeparatorInTime])
        
        let timestamp: String = formatter.string(from: now)
        return timestamp
    }
    
//    static func encodeToJSON(trajectory: Trajectory) -> Data? {
//        return try? JSONEncoder().encode(trajectory)
//    }
    
}

