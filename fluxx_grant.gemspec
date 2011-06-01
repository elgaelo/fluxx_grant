# -*- ruby -*-

begin
  require 'isolate/now'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install isolate` to install 'isolate' gem."
end

Gem::Specification.new do |s|
  s.rubyforge_project = "fluxx_grant"
  s.name              = "fluxx_grant"
  s.version           = "0.0.21"
  s.authors           = ["Eric Hansen"]
  s.email             = ["eric@fluxxlabs.com"]
  s.homepage          = "http://fluxxlabs.com"

  s.license           = "GPLv2"
  s.summary           = %q{Fluxx Grant Core}
  s.description       = %q{Fluxx Grant Code}

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test}/*`.split("\n")
  s.require_paths     = ["lib"]

  Isolate.sandbox.entries.each do |entry|
    if entry.environments.include?("development")
      s.add_development_dependency entry.name, *entry.requirement.as_list
    else
      s.add_dependency entry.name, *entry.requirement.as_list
    end
  end
end