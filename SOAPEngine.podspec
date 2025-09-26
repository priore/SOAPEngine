Pod::Spec.new do |s|
  s.name 				= 'SOAPEngine'
  s.version 			= '1.45'
  s.summary 			= 'This generic SOAP client allows you to access web services using a your iOS and Mac OS X app.'
  s.license 			= { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.authors 			= { 'Danilo Priore' => 'support@prioregroup.com' }
  s.homepage 			= 'https://github.com/priore/SOAPEngine'
  s.social_media_url 	= 'https://twitter.com/danilopriore'
  s.libraries 			= 'xml2'
  s.source 				= { git: 'https://github.com/priore/SOAPEngine.git', :tag => "#{s.version}" }
  s.xcconfig			= { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/**" }
  s.frameworks			= 'Security'
  
  s.ios.deployment_target    = '7.1'
  s.ios.public_header_files  = 'SOAPEngine/Headers/*.h'
  s.ios.source_files 		 = 'SOAPEngine/*.{h,m}'
  s.ios.xcconfig 			 = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2' }
  s.ios.framework			 = 'Accounts'

  s.osx.deployment_target    = '10.9'
  s.osx.public_header_files  = 'SOAPEngine/Headers/*.h'
  s.osx.source_files 		 = 'SOAPEngine/*.{h,m}'
  s.osx.framework			 = 'AppKit'
  s.osx.framework			 = 'Accounts'

  s.tvos.deployment_target	 	 = '9.0'
  s.tvos.public_header_files  	 = 'SOAPEngine/Headers/*.h'
  s.tvos.source_files 		 	 = 'SOAPEngine/*.{h,m}'
  s.tvos.xcconfig 			 	 = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2' }
end
