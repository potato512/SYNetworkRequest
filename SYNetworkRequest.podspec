Pod::Spec.new do |s|
  s.name         = "SYNetworkRequest"
  s.version      = "1.3.5"
  s.summary      = "SYNetworkRequest is network tool which used to request from network."
  s.homepage     = "https://github.com/potato512/SYNetworkRequest"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/potato512/SYNetworkRequest.git", :tag => "#{s.version}" }
  s.source_files  = "SYNetworkRequest/*.{h,m}"
  s.requires_arc = true
  s.dependency "AFNetworking"
end
