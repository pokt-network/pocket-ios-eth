# pocket-ios-eth
An Ethereum Plugin for the [Pocket iOS SDK](https://github.com/pokt-network/pocket-ios-sdk) that conforms to the `PocketPlugin` interface.  Uses `web3.swift` and `Cryptoswift` for core cryptography and Ethereum related functions. Conforms to the Pocket API guidelines.

# Install 
Need to install the following pod in your Podfile:

`pod 'SwiftKeychainWrapper', :git => 'git@github.com:jrendel/SwiftKeychainWrapper.git', :branch => 'develop', :commit => '77f73c354d695d976bcf1437fc9fbcea981aa2b4'`

`pod 'Pocket', :git => 'https://github.com/pokt-network/pocket-ios-eth.git', :branch => 'master'`

# Functionality

## Creating a Wallet

`public static func createWallet(data: [AnyHashable : Any]?) throws -> Wallet`

The wallet creation primarily uses the web3 library and the `SECP256k1.generatePrivateKey` function and saves to the keystore on the device. Developers do not have to worry about encrypting, storing or retrieving the wallet from the device. 

## Importing a Wallet

`public static func importWallet(privateKey: String, address: String?, data: [AnyHashable : Any]?) throws -> Wallet`

To import a wallet, the user must pass in their plaintext private key, and turn it into a hex of data using `Data(hex: privateKey)`. 

## Creating a Transaction

`public static func createTransaction(wallet: Wallet, params: [AnyHashable : Any]) throws -> Transaction`

To create an Ethereum transaction you need the following parameters:

- `nonce`: A counter that increments by +1 each time a transaction is created on an account
- `gasPrice`: The price of the transaction denominated in gwei
- `gasLimit`: Max amount of gas to be used for transaction
- `to` address: Public address receiving the transaction
- `value` (optional): Amount of ETH being sent in the transaction
- `data` field (optional): Data such as ABI of the function being called on a smart contract can be sent through the data field

By passing these in through the `params` dictionary the Ethereum plugin abstracts all the difficulty of creating transactions for the developer by returning a simple `Transaction` object.

## Creating a Query

`public static func createQuery(params: [AnyHashable : Any], decoder: [AnyHashable : Any]?) throws -> Query`

To create a Pocket Query for Ethereum you'll need the `params` for the specific [JSON RPC](https://github.com/ethereum/wiki/wiki/JSON-RPC) call you are wishing to make. There are two types of params to create a Query:

- `rpcMethod`: Name of the smart contract method you are calling 
- `rpcParams`: Inputs of the smart contract method you are calling

The `decoder` dictionary allows the developer to specify the return types from the read request. 



