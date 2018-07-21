//
//  PocketEth.swift
//  PocketEth
//
//  Created by Luis De Leon on 6/13/18.
//  Copyright © 2018 Luis De Leon. All rights reserved.
//

import Foundation
import Pocket
// TODO: Find a better way to do this
@testable import web3swift
import BigInt

public struct PocketEth: PocketPlugin {
    public static func createWallet(data: [AnyHashable : Any]?) throws -> Wallet {
        guard let privateKey = SECP256K1.generatePrivateKey() else {
            throw PocketPluginError.walletCreationError("Invalid private key")
        }
        guard let keyStore = PlainKeystore.init(privateKey: privateKey) else {
            throw PocketPluginError.walletCreationError("Invalid private key")
        }
        return try walletFromKeystore(keyStore: keyStore, data: data)
    }
    
    public static func importWallet(privateKey: String, address: String?, data: [AnyHashable : Any]?) throws -> Wallet {
        let privateKeyData = Data(hex: privateKey)
        guard let keyStore = PlainKeystore.init(privateKey: privateKeyData) else {
            throw PocketPluginError.walletCreationError("Invalid private key")
        }
        return try walletFromKeystore(keyStore: keyStore, data: data)
    }
    
    public static func createTransaction(wallet: Wallet, params: [AnyHashable : Any]) throws -> Transaction {
        // NONCE
        let nonceUint = params["nonce"] as? UInt ?? 0
        let nonce = BigUInt(nonceUint)
        
        // GAS PRICE (IN WEI)
        let gasPriceUint = params["gasPrice"] as? UInt ?? 0
        let gasPrice = BigUInt(gasPriceUint)
        
        // GAS LIMIT (IN WEI)
        let gasLimitUint = params["gasLimit"] as? UInt ?? 0
        let gasLimit = BigUInt(gasLimitUint)
        
        // TO
        guard let toString = params["to"] as? String else {
            throw PocketPluginError.transactionCreationError("Invalid TO param")
        }
        let to = EthereumAddress.init(toString, type: EthereumAddress.AddressType.normal)
        
        // VALUE
        let valueUint = params["value"] as? UInt ?? 0
        let value = BigUInt(valueUint)
        
        // DATA
        var ethTxData:Data? = nil
        if let data = params["data"] as? Data {
            ethTxData = data
        } else if let data = params["data"] as? [AnyHashable: Any] {
            if let functionABI = data["abi"] as? String, let funcParams = data["params"] as? [AnyObject] {
                ethTxData = PocketEth.encodeFunction(functionABI: functionABI, parameters: funcParams);
            }
        }
        
        // Create ethTx
        var ethTx:EthereumTransaction? = nil        
        if ethTxData != nil {
            ethTx = EthereumTransaction.init(nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, to: to!, value: value, data: ethTxData!, v: 0, r: 0, s: 0)
        } else {
            ethTx = EthereumTransaction.init(nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, to: to!, value: value, data: Data(), v: 0, r: 0, s: 0)
        }
        
        // Sign transaction
        ethTx?.chainID = BigUInt(1)
        try Web3Signer.EIP155Signer.sign(transaction: &ethTx!, privateKey: Data(hex: wallet.privateKey), useExtraEntropy: true)
        
        // Create pocket transaction
        let pocketTx = Transaction(obj: [AnyHashable: Any]())
        pocketTx.network = "ETH"
        guard let serializedTxData = ethTx?.encode() else {
            throw PocketPluginError.transactionCreationError("Error serializing signed transaction")
        }
        pocketTx.serializedTransaction = serializedTxData.toHexString().addHexPrefix()
        pocketTx.transactionMetadata = params
        
        return pocketTx
    }
    
    public static func createQuery(params: [AnyHashable : Any], decoder: [AnyHashable : Any]?) throws -> Query {
        let pocketQuery = Query()
        
        // Create data param
        var queryParams = [AnyHashable: Any]()
        if let rpcMethod = params["rpcMethod"] as? String, let rpcParams = params["rpcParams"] as? [Any] {
            queryParams["rpc_method"] = rpcMethod
            queryParams["rpc_params"] = rpcParams
        } else {
            throw PocketPluginError.queryCreationError("Invalid RPC params")
        }
        pocketQuery.data = queryParams
        
        // Create decoder param
        var decoderParams = [AnyHashable: Any]()
        if decoder != nil {
            if let returnTypes = decoder!["returnTypes"] as? [String] {
                decoderParams["return_types"] = returnTypes
            }
        }
        pocketQuery.decoder = decoderParams
        
        // Assign network
        pocketQuery.network = "ETH"
        
        return pocketQuery
    }
    
    public static func encodeFunction(functionABI: String, parameters: [AnyObject]) -> Data {
        let function = try! JSONDecoder().decode(ABIv2.Record.self, from: functionABI.data(using: .utf8)!).parse()
        return function.encodeParameters(parameters)!
    }
}

func walletFromKeystore(keyStore: PlainKeystore, data: [AnyHashable : Any]?) throws -> Wallet {
    guard let address = keyStore.addresses?.first else {
        throw PocketPluginError.walletCreationError("Invalid wallet address")
    }
    let keystorePrivateKey = try keyStore.UNSAFE_getPrivateKeyData(account: address).toHexString()
    let wallet = Wallet(address: address.address, privateKey: keystorePrivateKey, network: "ETH", data: data)
    return wallet
}

