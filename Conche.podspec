Pod::Spec.new do |s|
  s.name         = "Conche"
  s.version      = "1.0.1"
  s.summary      = "A lightweight Objective-C state machine framework"

  s.description  = <<-DESC
Conche is a lightweight framework for implementing state machines in Objective-C.  It is designed with the following goals in mind:

- High scalability via non-blocking design.
- Precise control of the state machine class via its `resume`, `suspend`, and `invalidate` methods.
- Flexibility through subclassing.
DESC

  s.homepage     = "https://github.com/djs-code/Conche"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/djs-code/Conche.git", :tag => "1.0.1" }
  s.source_files  = "Conche/*.{h,m}"

  s.requires_arc = true
end
