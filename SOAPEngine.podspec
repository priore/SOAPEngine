Pod::Spec.new do |s|
  s.name                  = 'SOAPEngine'
  s.version               = '1.45'
  s.summary               = 'This generic SOAP client allows you to access web services using your iOS, macOS, and tvOS app.'
  s.description           = <<-DESC
  A comprehensive and generic SOAP client for Apple platforms, allowing easy access and communication with web services.
  DESC
  s.license               = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.authors               = { 'Danilo Priore' => 'support@prioregroup.com' }
  s.homepage              = 'https://github.com/priore/SOAPEngine'
  s.social_media_url      = 'https://twitter.com/danilopriore'
  s.source                = { git: 'https://github.com/priore/SOAPEngine.git', :tag => "#{s.version}" }
  s.requires_arc          = true
  s.pod_target_xcconfig   = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'OTHER_LDFLAGS' => '-lxml2'
  }
  s.libraries             = 'xml2'
  s.xcconfig              = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  s.source_files          = 'SOAPEngine/**/*.{h,m,pch}'
  s.public_header_files   = 'SOAPEngine/Headers/*.h'
  s.ios.deployment_target   = '12.0'
  s.ios.framework           = 'Accounts'
  s.ios.frameworks          = 'Security'
  s.osx.deployment_target   = '10.13'
  s.osx.framework           = 'AppKit'
  s.osx.frameworks          = 'Security'
  s.osx.framework           = 'Accounts'
  s.tvos.deployment_target  = '12.0'
  s.tvos.frameworks         = 'Security'
  
end
