# pocket-ios-eth
An Ethereum Plugin for the [Pocket iOS SDK](https://github.com/pokt-network/pocket-ios-sdk) that conforms to the `PocketPlugin` interface.  Uses `web3.swift` and `Cryptoswift` for core cryptography and Ethereum related functions. Conforms to the [Pocket API](https://github.com/pokt-network/pocket-api/blob/master/documentation/blueprint.apib) guidelines.

# Install 
Need to install the following pod in your Podfile:

`pod 'SwiftKeychainWrapper', :git => 'git@github.com:jrendel/SwiftKeychainWrapper.git', :branch => 'develop', :commit => '77f73c354d695d976bcf1437fc9fbcea981aa2b4'`

`pod 'Pocket', :git => 'https://github.com/pokt-network/pocket-ios-eth.git', :branch => 'master'`

# Functionality

## Creating a Wallet

`public static func createWallet(data: [AnyHashable : Any]?) throws -> Wallet`

The wallet creation primarily uses the web3 library and the `SECP256k1.generatePrivateKey` function and saves to the keystore on the device. Developers do not have to worry about encrypting, storing or retrieving the wallet from the device.

Example from [BANANO Quest](https://github.com/pokt-network/banano-quest):

```
let wallet = try PocketEth.createWallet(data: nil)
if try wallet.save(passphrase: walletPassphrase) == false {
    throw PlayerPersistenceError.walletCreationError
}
```

## Importing a Wallet

`public static func importWallet(privateKey: String, address: String?, data: [AnyHashable : Any]?) throws -> Wallet`

To import a wallet, the user must pass in their plaintext private key. 

## Creating a Transaction

`public static func createTransaction(wallet: Wallet, params: [AnyHashable : Any]) throws -> Transaction`

To create an Ethereum transaction you need the following parameters:

- `nonce`: A counter that increments by +1 each time a transaction is created on an account. You can retrieve the current transaction count using `eth_getTransactionCount` Query
- `gasPrice`: The price of the transaction denominated in wei
- `gasLimit`: Max amount of gas to be used for transaction denominated in wei
- `to` address: Public address receiving the transaction
- `value` (optional): Amount of ETH being sent in the transaction
- `data` field (optional): Data such as ABI of the function being called on a smart contract can be sent through the data field

By passing these in through the `params` dictionary the Ethereum plugin abstracts all the difficulty of creating transactions for the developer by returning a simple `Transaction` object. An example transaction in creating a Quest in BANANO Quest:


### Define contract function ABI
```
let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_maxWinners\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_merkleBody\",\"type\":\"string\"},{\"name\":\"_metadata\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"
```

### Define parameters
```
var functionParameters = [AnyObject]()
functionParameters.append(tokenAddress as AnyObject)
functionParameters.append(questName.description as AnyObject)
functionParameters.append(hint.description as AnyObject)
functionParameters.append(maxWinners as AnyObject)
functionParameters.append(merkleRoot as AnyObject)
functionParameters.append(merkleBody as AnyObject)
functionParameters.append(metadata as AnyObject)

let txParams = [
    "from": wallet.address,
    "nonce": BigUInt.init(transactionCount),
    "to": tavernAddress,
    "value": BigUInt.init(ethPrizeWei),
    "chainID": AppConfiguration.chainID,
    "gasLimit": BigUInt.init(2000000),
    "gasPrice": BigUInt.init(1000000000),
    "data": [
        "abi": functionABI,
        "params": functionParameters
    ] as [AnyHashable: Any]
] as [AnyHashable: Any]
```

### Create transaction
```
guard let transaction = try? PocketEth.createTransaction(wallet: wallet, params: txParams) else {
self.error = PocketPluginError.transactionCreationError("Error creating transaction")
self.finish()
return
}
```

### Send Transaction
```
Pocket.shared.sendTransaction(transaction: transaction) { (transactionResponse, error) in
if error != nil {
self.error = error
self.finish()
return
}
```
### Parse transaction hash response
```
guard let txHash = transactionResponse?.hash else {
self.error = UploadQuestOperationError.invalidTxHash
self.finish()
return
}

self.txHash = txHash
self.finish()
```



## Creating a Query

`public static func createQuery(params: [AnyHashable : Any], decoder: [AnyHashable : Any]?) throws -> Query`

To create a Pocket Query for Ethereum you'll need the `params` for the specific [JSON RPC](https://github.com/ethereum/wiki/wiki/JSON-RPC) call you are wishing to make. There are two types of params to create a Query:

- `rpcMethod`: Name of the smart contract method you are calling 
- `rpcParams`: Inputs of the smart contract method you are calling

The `decoder` dictionary allows the developer to specify the return types from the read request. 

An example in creating a `getBalance` Query and getting the balance of an account using Pocket: 

```        
let params = [
"rpcMethod": "eth_getBalance",
"rpcParams": [address, "latest"]
] as [AnyHashable: Any]

guard let query = try? PocketEth.createQuery(params: params, decoder: nil) else {
self.error = PocketPluginError.queryCreationError("Error creating query")
self.finish()
return
}

Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
if error != nil {
self.error = error
self.finish()
return
}
```

Creating a Query for a smart contract constant is a little bit more involved, as you need to provide the ABI interface for the method you are calling, the `functionParameters` and the `decoder`. An example in getting a list of Quests from BANANO Quest: 

Create transaction
```
var tx = [AnyHashable: Any]()
```


### Create ABI

```
let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"}],\"name\":\"getQuest\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bool\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
```

### Pass in address and index
```
let functionParameters = [tokenAddress, questIndex] as [AnyObject]
```

### Encode the ABI and parameters
```
guard let data = try? PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString() else {
self.error = PocketPluginError.queryCreationError("Error creating query")
self.finish()
return
}
```

### Add parameters for an Ethereum transaction
```
tx["to"] = tavernAddress
tx["data"] = "0x" + data
tx["from"] = self.playerAddress
```

### Create the parameters for the final Ethereum Query
```
let params = [
"rpcMethod": "eth_call",
"rpcParams": [tx, "latest"]
] as [AnyHashable: Any]
```

### Create the decoder
```
let decoder = [
"returnTypes": ["address", "uint256", "string", "string", "bytes32", "string", "uint256", "string", "bool", "uint256", "uint256"]
] as [AnyHashable : Any]
```

### Create Query object
```
guard let query = try? PocketEth.createQuery(params: params, decoder: decoder) else {
self.error = PocketPluginError.queryCreationError("Error creating query")
self.finish()
return
}
```

### Execute the Query
```
Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
if error != nil {
self.error = error
self.finish()
return
}
```
### Get and parse response
```
guard let questArr = queryResponse?.result?.value() as? [JSON] else {
    self.error = DownloadQuestOperationError.questParsing
    self.finish()
    return
}

    let creator = questArr[0].value() as? String ?? ""
    let index = questArr[1].value() as? String ?? "0"
    let name = questArr[2].value() as? String ?? ""
    let hint = questArr[3].value() as? String ?? ""
    let merkleRoot = questArr[4].value() as? String ?? ""
    let merkleBody = questArr[5].value() as? String ?? ""
    let maxWinners = questArr[6].value() as? String ?? "0"
    let metadata = questArr[7].value() as? String ?? ""
    let valid = questArr[8].value() as? Bool ?? false
    let winnersAmount = questArr[9].value() as? String ?? "0"
    let claimersAmount = questArr[10].value() as? String ?? "0"

self.questDict = [
    "creator": creator,
    "index": index,
    "name": name,
    "hint": hint,
    "merkleRoot": merkleRoot,
    "merkleBody": merkleBody,
    "maxWinners": maxWinners,
    "metadata": metadata,
    "valid": valid,
    "winnersAmount": winnersAmount,
    "claimersAmount": claimersAmount
] as [AnyHashable: Any]
    self.finish()

```




