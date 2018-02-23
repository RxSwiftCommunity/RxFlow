Pod::Spec.new do |s|

  s.name         = "RxFlow"
  s.version      = "1.2.0"
  s.summary      = "RxFlow is a navigation framework for iOS applications, based on a Reactive Coordinator pattern."

  s.description  = <<-DESC
RxFlow aims to

* Promote the cutting of storyboards into atomic units to enable collaboration and reusability of UIViewControllers
* Allow the presentation of a UIViewController in different ways according to the navigation context
* Ease the implementation of dependency injection
* Remove any navigation mechanism from UIViewControllers
* Promote reactive programing
* Express the navigation in a declarative way while addressing the majority of the navigation cases
* Facilitate the cutting of an application into logical blocks of navigation
                   DESC

  s.homepage     = "https://github.com/RxSwiftCommunity/RxFlow"
  s.screenshots  = "https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow_logo.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Thibault Wittemberg" => "thibault.wittemberg@gmail.com", "RxSwiftCommunity" => "https://github.com/RxSwiftCommunity" }
  s.social_media_url   = "http://twitter.com/thwittem"
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/RxSwiftCommunity/RxFlow.git", :tag => s.version.to_s }
  s.source_files  = "RxFlow/**/*.swift"
  s.frameworks  = 'UIKit'
  s.requires_arc     = true  
  s.dependency 'RxSwift', '>= 4.0.0'
  s.dependency 'RxCocoa', '>= 4.0.0'

end
