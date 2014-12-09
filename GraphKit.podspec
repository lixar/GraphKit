Pod::Spec.new do |s|
  s.name         = "GraphKit"
  s.version      = "1.1.2"
  s.summary      = "A lightweight library of animated charts for iOS."
  s.homepage     = "https://github.com/lixar/GraphKit"
  s.license      = 'MIT'

  s.author       = { 
    "Michal Konturek" => "michal.konturek@gmail.com"
  }

  s.ios.deployment_target = '7.0'
  
  s.source       = { 
    :git => "https://github.com/lixar/GraphKit.git", 
    :tag => s.version.to_s
  }

  s.source_files = 'Source/**/*.{h,m}'
  s.requires_arc = true

  s.dependency 'FrameAccessor', '~> 1.3.2'
  s.dependency 'MKFoundationKit/NSArray', '~> 1.2.2'
end