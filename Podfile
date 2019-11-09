platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

def common_pods
    pod 'Firebase/Auth', '6.12.0'
    pod 'Firebase/Core', '6.12.0'
    pod 'Firebase/Database', '6.12.0'
    pod 'Firebase/RemoteConfig', '6.12.0'
    pod 'Firebase/Storage', '6.12.0'
    pod 'GoogleSignIn', '5.0.1'
    pod 'Kingfisher', '4.10.1'
end

target 'RigaDevDays' do
    common_pods

    target 'RigaDevDaysTests' do
        inherit! :search_paths
    end
end

target 'DevFest' do
    common_pods
end

target 'FrontCon' do
    common_pods
end

target 'DevOpsDaysRiga' do
    common_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        end
    end
end
