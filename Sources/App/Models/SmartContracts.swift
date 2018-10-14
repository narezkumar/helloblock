//
//  SmartContracts.swift
//  App
//
//  Created by Mohammad Azam on 3/23/18.
//

import Foundation

class DrivingRecordSmartContract : Codable {
    
    func apply(transaction :Transaction, allBlocks :[Block]) {
        
        allBlocks.forEach { block in
            
            block.transactions.forEach { trans in
                
                if trans.from == transaction.from {
                    transaction.amount += 1
                }
                
                if transaction.amount > 1 {
                    transaction.to = "Invalid"
                }
                
            }
            
        }
        
    }
    
}
