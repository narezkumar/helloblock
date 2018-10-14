
//: Playground - noun: a place where people can play

import Vapor
import Crypto

final class BlockchainNode :Content {
    
    var address :String
    
    init(address :String) {
        self.address = address
    }
    
}

final class Driving : Content {
    
    var from :String
    
    init(from :String) {
        self.from = from
        do {
         let digest = try SHA1.hash(self.from)
         self.from = digest.hexEncodedString()
        }catch {}
    }
}

final class Transaction : Content {
    
    var from :String
    var to :String
    var amount :Double
    
    init(from :String, to :String, amount :Double) {
        self.to = to
        self.amount = amount
        self.from = from
        do {
            let digest = try SHA1.hash(self.from)
            self.from = digest.hexEncodedString()
        }catch {}
    }
}

final class Block : Content  {
    
    var index :Int = 0
    var previousHash :String = ""
    var hash :String!
    var nonce :Int
    
    private (set) var transactions :[Transaction] = [Transaction]()
    
    var key :String {
        get {
            
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding: .utf8)
            
            return String(self.index) + self.previousHash + String(self.nonce) + transactionsJSONString!
        }
    }
    
    func addTransaction(transaction :Transaction) {
        self.transactions.append(Transaction.init(from: transaction.from, to: transaction.to, amount: transaction.amount))
    }
    
    init() {
        self.nonce = 0
    }
    
}

final class Blockchain : Content  {
    
    private (set) var blocks = [Block]()
    private (set) var nodes = [BlockchainNode]()
    private (set) var drivingRecordSmartContract = DrivingRecordSmartContract()

    init(genesisBlock :Block) {
        addBlock(genesisBlock)
    }
    
    func registerNodes(nodes :[BlockchainNode]) -> [BlockchainNode] {
        self.nodes.append(contentsOf: nodes)
        return self.nodes
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            block.previousHash = "0000000000000000"
            block.hash = generateHash(for :block)
        }
        
        self.blocks.append(block)
    }
    
    func transactionsBy(drivingLicenseNumber :Driving) -> [Transaction] {
        
        let drivingLicenseNumber2 = Driving.init(from: drivingLicenseNumber.from)
        var transactions = [Transaction]()
        self.blocks.forEach { block in
            block.transactions.forEach { transaction in
                
                if transaction.from == drivingLicenseNumber2.from {
                    transactions.append(transaction)
                }
            }
        }
        return transactions
        
    }
    
    func getNextBlock(transactions :[Transaction]) -> Block {
        
        let block = Block()
        transactions.forEach { transaction in
            // applying smart contract
            self.drivingRecordSmartContract.apply(transaction: transaction, allBlocks: self.blocks)
            block.addTransaction(transaction: transaction)
        }
        
        let previousBlock = getPreviousBlock()
        block.index = self.blocks.count
        block.previousHash = previousBlock.hash
        block.hash = generateHash(for: block)
        return block
        
    }
    
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    func generateHash(for block :Block) -> String {
        
        var hash = "-"
        do {
            let digest = try SHA1.hash(block.key)
            hash = digest.hexEncodedString()
        }catch {}
        
        while(!hash.hasPrefix("000")) {
            block.nonce += 1
            do {
                let digest = try SHA1.hash(block.key)
                hash = digest.hexEncodedString()
            }catch {}
            print(hash)
        }
        
        return hash
    }
    
}







