source 'https://rubygems.org'

# Get local or master 'rspec-hollerback-mocks' gem
library_path = File.expand_path("../../rspec-hollerback-mocks", __FILE__)
if File.exist?(library_path)
  gem 'rspec-hollerback-mocks', path: library_path
else
  gem 'rspec-hollerback-mocks', git: "git://github.com/delner/rspec-hollerback-mocks.git",
                    branch: ENV.fetch('BRANCH',"master")
end

gemspec
