require 'bundler/setup'
Bundler.require

Dir.chdir(File.expand_path('..', __dir__))
$LOAD_PATH.unshift(File.expand_path(__dir__))

require 'atebit'
