
Pod::Spec.new do |s|
  s.name         = "P41Sketch"
  s.version      = "1.0.0"
  s.summary      = "P41Sketch"
  s.description  = <<-DESC
                  P41Sketch
                   DESC
  s.homepage     = "https://github.com/VGamezz19/react-native-sketch-draw"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/P41Sketch.git", :tag => "v#{s.version}" }
  s.source_files  = "P41Sketch/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

