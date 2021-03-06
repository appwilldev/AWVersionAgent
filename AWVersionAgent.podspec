Pod::Spec.new do |s|
  s.name         = "AWVersionAgent"
  s.version      = "0.0.7"
  s.summary      = "Check and notify user that new version is available from Local Notification."
  s.homepage     = "https://github.com/appwilldev/AWVersionAgent"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Heyward Fann" => "fannheyward@gmail.com" }
  s.source       = { :git => "https://github.com/appwilldev/AWVersionAgent.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.source_files = 'AWVersionAgent/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.dependency 'EDSemver', '~> 0.3.1'
end
