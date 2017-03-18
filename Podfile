inhibit_all_warnings!
use_frameworks!

def common_pods
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/RemoteConfig'
    pod 'Firebase/Storage'
    pod 'GoogleSignIn'
    pod 'Kingfisher'
end

target 'RigaDevDays' do
    common_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        end
    end
end
