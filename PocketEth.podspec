# PocketEth
#
# Verifying:
# pod lib lint PocketEth.podspec --allow-warnings
#
# Releasing:
# pod repo push master PocketEth.podspec --allow-warnings

Pod::Spec.new do |s|
  # Meta
  s.name      = 'PocketEth'
  s.version   = '0.0.1'
  s.license   = { :type => 'MIT' }
  s.homepage  = 'https://github.com/pokt-network/pocket-ios-eth'
  s.authors   = { 'Luis C. de Leon' => 'luis@pokt.network' }
  s.summary   = 'An Ethereum Plugin for the Pocket iOS SDK.'

  # Settings
  s.source            = { :git => 'https://github.com/pokt-network/pocket-ios-eth.git', :tag => s.version.to_s }
  s.source_files      = 'PocketEth/**/*.{swift}', 'PocketEthTests/**/*.{swift}'
  s.exclude_files     = 'docs/*'
  s.swift_version     = '4.0'
  s.cocoapods_version = '>= 1.4.0'

  # Deployment Targets
  s.ios.deployment_target = '11.4'
  s.dependency 'Pocket'
  s.dependency 'web3swift'
  s.dependency 'CryptoSwift'
  s.dependency 'SwiftKeychainWrapper'
end
