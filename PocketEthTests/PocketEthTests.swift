//
//  PocketEthTests.swift
//  PocketEthTests
//
//  Created by Luis De Leon on 6/13/18.
//  Copyright © 2018 Luis De Leon. All rights reserved.
//

import XCTest
@testable import PocketEth

class PocketEthTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Tests for createWallet()
    func testCreateWalletSuccess() {
        let pk = "12345678"
        let wallet = try? PocketEth.createWallet(privateKey: pk, data: nil)
        XCTAssertEqual(pk, wallet?.privateKey)
        XCTAssertEqual("ETH", wallet?.network)
    }
    
    func testCreateWalletPKError() {
        let pk = ""
        XCTAssertThrowsError(try? PocketEth.createWallet(privateKey: pk, data: nil))
    }
    
    // Tests for createTransaction()
    func testCreateTransactionSuccess() {
        let pk = "12345678"
        let wallet = try? PocketEth.createWallet(privateKey: pk, data: nil)
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_numTokens\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_uri\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        let functionParams = ["Test Quest", "Test Hint", 10, "Test Merkle Root", "Test URI"] as [Any]
        var dataParams = [AnyHashable: Any]()
        dataParams["abi"] = functionABI
        dataParams["params"] = functionParams
        
        var params = [AnyHashable : Any]()
        params["to"] = "0x0"
        params["data"] = dataParams
        
        let transaction = try? PocketEth.createTransaction(wallet: wallet!, params: params)
        XCTAssertNotNil(transaction)
        XCTAssertNotNil(transaction?.serializedTx)
        XCTAssertEqual("ETH", transaction?.network)
    }
    
    func testCreateTransactionTOError() {
        let pk = "12345678"
        let wallet = try? PocketEth.createWallet(privateKey: pk, data: nil)
        
        var params = [AnyHashable : Any]()
        params["to"] = nil
        
        XCTAssertThrowsError(try? PocketEth.createTransaction(wallet: wallet!, params: params))
    }
    
    // Tests for createQuery()
    func testCreateQuerySuccess() {
        
    }
    
    func testCreateQueryRPCError() {
        
    }
}
