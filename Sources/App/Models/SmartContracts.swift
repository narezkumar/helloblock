//
//  SmartContracts.swift
//  App
//
//  Created by Mohammad Azam on 3/23/18.
//

import Foundation
import Crypto

class LoyaltyRankSmartContract : Codable {
    
    func apply(transaction :Transaction, allBlocks :[Block]) {
        
        var hashPassport = ""
        
        do {
            let digest = try SHA1.hash(transaction.passport)
            hashPassport = digest.hexEncodedString()
        }catch {}
        
        allBlocks.forEach { block in

            block.transactions.forEach { trans in
                if trans.passport == hashPassport {
                    transaction.level = nextLetter(trans.level) ?? "A"
                }
            }
            
        }
        
    }
    
    func nextLetter(_ letter: String) -> String? {
        
        // Check if string is build from exactly one Unicode scalar:
        guard let uniCode = UnicodeScalar(letter) else {
            return nil
        }
        switch uniCode {
        case "A" ..< "Z":
            return String(UnicodeScalar(uniCode.value + 1)!)
        default:
            return nil
        }
    }
    
}
