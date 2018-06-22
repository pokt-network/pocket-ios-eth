# Uncomment the next line to define a global platform for your project
platform :ios, '11.4'

target 'PocketEth' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    pod 'Pocket', :git => 'https://github.com/pokt-network/pocket-ios-sdk.git', :branch => 'master', :commit => 'bc0d02d7882f3fe935ac6fe83293a4b80a5a7a49'
    pod 'web3swift'
    pod 'CryptoSwift'
    pod 'SwiftKeychainWrapper', :git => 'git@github.com:jrendel/SwiftKeychainWrapper.git', :branch => 'develop', :commit => '77f73c354d695d976bcf1437fc9fbcea981aa2b4'

    target 'PocketEthTests' do
        inherit! :search_paths
        # Pods for testing
    end

end
