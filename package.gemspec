Gem::Specification.new do |s|
  s.name = 'rails_markdown'
  s.version = '0.0.1'
  s.authors = ['MingyuanQin']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/work-design/rails_markdown'
  s.summary = '加载 Markdown'
  s.description = 'Description of RailsMarkdown.'
  s.license = 'MIT'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails_com'
  s.add_dependency 'kramdown'
  s.add_dependency 'nokogiri'
end
