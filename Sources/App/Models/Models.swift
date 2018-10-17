
//: Playground - noun: a place where people can play

import Vapor
import Crypto

final class BlockchainNode :Content {
    
    var address :String
    
    init(address :String) {
        self.address = address
    }
    
}

final class PhoneNumber : Content {
    
    var isocountry :String
    
    init(isocountry :String) {
        self.isocountry = isocountry
    }
}

final class LoyaltyRank : Content {
    
    var passport :String
    
    init(passport :String) {
        self.passport = passport
        do {
         let digest = try SHA1.hash(self.passport)
         self.passport = digest.hexEncodedString()
        }catch {}
    }
}

final class PhoneTransaction : Content {
    
    var phone_number :String
    var phone_region :String
    var phone_postal_code :String
    var phone_iso_country :String
    var phone_voice :String
    var phone_sms :String
    var isavailable :String
    
    init(phone_number :String, phone_region :String, phone_postal_code :String, phone_iso_country :String, phone_voice :String, phone_sms :String, isavailable :String) {
        self.phone_number = phone_number
        self.phone_region = phone_region
        self.phone_postal_code = phone_postal_code
        self.phone_iso_country = phone_iso_country
        self.phone_voice = phone_voice
        self.phone_sms = phone_sms
        self.isavailable = isavailable
    }
}

final class Transaction : Content {
    
    var passport :String
    var spent :String
    var used :String
    var level :String
    var phone_number :String
    var phone_region :String
    var phone_postal_code :String
    var phone_iso_country :String
    var phone_voice :String
    var phone_sms :String
    var isavailable :String

    init(passport :String, spent :String, used :String, level :String, phone_number :String, phone_region :String, phone_postal_code :String, phone_iso_country :String, phone_voice :String, phone_sms :String, isavailable :String) {
        self.passport = passport
        self.spent = spent
        self.used = used
        self.level = level
        self.phone_number = phone_number
        self.phone_region = phone_region
        self.phone_postal_code = phone_postal_code
        self.phone_iso_country = phone_iso_country
        self.phone_voice = phone_voice
        self.phone_sms = phone_sms
        self.isavailable = isavailable
        do {
            let digest = try SHA1.hash(self.passport)
            self.passport = digest.hexEncodedString()
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
        self.transactions.append(Transaction.init(passport: transaction.passport, spent: transaction.spent, used: transaction.used, level: transaction.level, phone_number: transaction.phone_number, phone_region: transaction.phone_region, phone_postal_code: transaction.phone_postal_code, phone_iso_country: transaction.phone_iso_country, phone_voice: transaction.phone_voice, phone_sms: transaction.phone_sms, isavailable: transaction.isavailable))
    }
    
    init() {
        self.nonce = 0
    }
    
}

final class Blockchain : Content  {
    
    private (set) var blocks = [Block]()
    private (set) var nodes = [BlockchainNode]()
    private (set) var loyaltyRankSmartContract = LoyaltyRankSmartContract()

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
    
    func transactionsBy(passportLoyaltyRank :LoyaltyRank) -> [Transaction] {
        
        let twoLoyaltyRank = LoyaltyRank.init(passport: passportLoyaltyRank.passport)
        var transactions = [Transaction]()
        self.blocks.forEach { block in
            block.transactions.forEach { transaction in
                
                if transaction.passport == twoLoyaltyRank.passport {
                    transactions.append(transaction)
                }
            }
        }
        return transactions
        
    }
    
    func transactionsByPhone(phone :PhoneNumber) -> [PhoneTransaction] {
        
        var transactions = [PhoneTransaction]()
        self.blocks.forEach { block in
            block.transactions.forEach { transaction in
                
                if transaction.phone_iso_country == phone.isocountry {
                    transactions.append(PhoneTransaction.init(phone_number: transaction.phone_number, phone_region: transaction.phone_region, phone_postal_code: transaction.phone_postal_code, phone_iso_country: transaction.phone_iso_country, phone_voice: transaction.phone_voice, phone_sms: transaction.phone_sms, isavailable: transaction.isavailable))
                }
            }
        }
        return transactions
        
    }
    
    func getNextBlock(transactions :[Transaction]) -> Block {
        
        let block = Block()
        transactions.forEach { transaction in
            // applying smart contract
            self.loyaltyRankSmartContract.apply(transaction: transaction, allBlocks: self.blocks)
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
        let terminal = Terminal()

        var hash = "-"
        do {
            let digest = try SHA1.hash(block.key)
            hash = digest.hexEncodedString()
        }catch {}
        
        while(!hash.hasPrefix("0000")) {
            block.nonce += 1
            do {
                let digest = try SHA1.hash(block.key)
                hash = digest.hexEncodedString()
            }catch {}
            terminal.print("SHA1 hash \(hash)")

        }
        
        return hash
    }
    
}







