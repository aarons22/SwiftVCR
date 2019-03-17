Pod::Spec.new do |s|
  s.name             = 'VCR'
  s.version          = '0.1.0'
  s.summary          = 'VCR is a lightweight tool to record and playback http requests for mocking in swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  VCR is a lightweight tool to record and playback http requests for mocking in swift. 
  Inspired by VCR for Rails, this tool allows you to record requests via URLSession.
                       DESC

  s.homepage         = 'https://github.com/aarons22/SwiftVCR'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Sapp' => 'sapp.aaron@gmail.com' }
  s.source           = { :git => 'https://github.com/aarons22/SwiftVCR.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/aaronsapp'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/**/*'
  
  # s.resource_bundles = {
  #   'VCR' => ['VCR/Assets/*.png']
  # }
end
