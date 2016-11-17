platform :ios, '7.0'
target 'Horoscopes' do
	pod 'GoogleAnalytics', '~> 3.13'
	pod 'Reachability'
	pod 'JSONKit-NoWarning'
	pod 'FBSDKCoreKit', '~> 4.7'
	pod 'UIImage+animatedGif'
	pod 'MBProgressHUD'
    pod 'FBSDKLoginKit', '~> 4.7'
    pod 'FBSDKShareKit', '~> 4.7'
    pod 'MZFormSheetController'
    pod 'WebASDKImageManager'
    pod 'Google-Mobile-Ads-SDK', '~> 7.5'
    pod 'AFNetworking', '~> 2.6'
    pod 'JTCalendar', '~> 2.0'
    pod 'CustomIOSAlertView', '~> 0.9.3'
    pod 'CCHLinkTextView'
    pod 'DateTools'
    pod 'Firebase/Core'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
