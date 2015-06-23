Pod::Spec.new do |s|
  s.name             = "RZViewActions"
  s.version          = "0.2.1"
  s.summary          = "Sequenced and grouped animations for UIView"
  s.description      = <<-DESC
                       A category on UIView that provides animation structure similar to SKAction from SpriteKit.
                       DESC
  s.homepage         = "https://github.com/Raizlabs/RZViewActions"
  s.license          = 'MIT'
  s.author           = { "Rob Visentin" => "rob.visentin@raizlabs.com" }
  s.source           = { :git => "https://github.com/Raizlabs/RZViewActions.git", :tag => s.version.to_s }

  s.platform     = :ios, '4.0'
  s.requires_arc = true

  s.frameworks = 'UIKit'

  s.source_files = 'RZViewActions'
end
