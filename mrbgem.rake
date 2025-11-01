require_relative "./resolve"

MRuby::Gem::Specification.new('mruby-bin-mrbuild') do |spec|
  spec.license = 'MIT'
  spec.author  = 'skinnyjames'
  spec.summary = 'mruby build tool'
  spec.version = '0.1.0'
  spec.add_dependency "mruby-class-ext"
  spec.add_dependency 'mruby-metaprog'
  spec.add_dependency 'mruby-file-stat'
  spec.add_dependency 'mruby-dir'
  spec.add_dependency 'mruby-dir-glob'
  spec.add_dependency 'mruby-bin-theorem'
  spec.bins = ["mrbuild"]
end