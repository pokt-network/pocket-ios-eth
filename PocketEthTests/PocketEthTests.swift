//
//  PocketEthTests.swift
//  PocketEthTests
//
//  Created by Luis De Leon on 6/13/18.
//  Copyright © 2018 Luis De Leon. All rights reserved.
//

import XCTest
//import PocketEth
import Pocket
@testable import PocketEth

class PocketEthTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWalletValidity(wallet: Wallet) {
        XCTAssertNotNil(wallet)
        XCTAssertNotNil(wallet.address)
        XCTAssertNotNil(wallet.privateKey)
        XCTAssertNotNil(wallet.network)
    }
    
    // Tests for createWallet()
    func testCreateWalletSuccess() {
        let wallet = try? PocketEth.createWallet(data: nil)
        testWalletValidity(wallet: wallet!)
    }
    
    // Tests for importWallet()
    func testImportWallet() {
        let walletToImport = try? PocketEth.createWallet(data: nil)
        let importedWallet = try? PocketEth.importWallet(privateKey: (walletToImport?.privateKey)!, address: walletToImport?.address, data: walletToImport?.data)
        testWalletValidity(wallet: importedWallet!)
        XCTAssertEqual(walletToImport?.privateKey, importedWallet?.privateKey)
        XCTAssertEqual(walletToImport?.address, importedWallet?.address)
        XCTAssertEqual(walletToImport?.network, importedWallet?.network)
    }
    
    // Tests for createTransaction()
    func testCreateTransactionSuccess() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_numTokens\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_uri\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        let functionParams = ["Test Quest", "Test Hint", 10, "Test Merkle Root", "Test URI"] as [Any]
        var dataParams = [AnyHashable: Any]()
        dataParams["abi"] = functionABI
        dataParams["params"] = functionParams

        var params = [AnyHashable : Any]()
        params["to"] = "0xE1B33AFb88C77E343ECbB9388829eEf6123a980a"
        params["data"] = dataParams
        
        let wallet = try? PocketEth.createWallet(data: nil)
        let transaction = try? PocketEth.createTransaction(wallet: wallet!, params: params)
        XCTAssertNotNil(transaction)
        XCTAssertNotNil(transaction?.serializedTransaction)
        XCTAssertEqual("ETH", transaction?.network)
    }
    
    func testCreateTransactionTOError() {
        let wallet = try? PocketEth.createWallet(data: nil)
        
        var params = [AnyHashable : Any]()
        params["to"] = nil
        
        XCTAssertThrowsError(try PocketEth.createTransaction(wallet: wallet!, params: params))
    }
    
    // Tests for createQuery()
    func testCreateQuerySuccess() {
        let query = try? PocketEth.createQuery(params: ["rpcMethod": "eth_getTransactionCount", "rpcParams": ["0x0", "latest"]], decoder: nil)
        XCTAssertNotNil(query)
        XCTAssertNotNil(query?.data)
        XCTAssertEqual(query?.network, "ETH")
        XCTAssertNotNil(query?.decoder)
    }
    
    func testCreateQueryRPCError() {
        XCTAssertThrowsError(try PocketEth.createQuery(params: ["failedKey": "failedValue"], decoder: nil))
    }
}
