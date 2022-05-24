enable_test = true

Pod::Spec.new do |spec|

  spec.name         = "ConcurrencyFoundation"
  spec.version      = "0.0.1"
  spec.summary      = "An easy-to-use and lightweight concurrency utilities for thread safty in swift
."
  spec.homepage     = "https://github.com/tjerwinchen/#{spec.name}"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Theo Chen" => "theo.chen@codebase.codes" }
  spec.social_media_url   = "https://twitter.com/zhecuichen"

  spec.swift_version = '5.6'
  spec.ios.deployment_target = "12.0"
  spec.osx.deployment_target = "10.13"
  spec.watchos.deployment_target = "5.0"
  spec.tvos.deployment_target = "12.0"


  spec.source       = { :git => "#{spec.homepage}.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/#{spec.name}/**/*.{h,m,swift}"
  
  if enable_test
    spec.test_spec 'Tests' do |test_spec|
      test_spec.source_files = "Tests/#{spec.name}Tests/**/*.{h,m,swift}"
    end
  end
end
