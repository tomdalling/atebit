# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'atebit'
set :repo_url, "https://github.com/tomdalling/atebit.git"
set :chruby_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :pty, true
