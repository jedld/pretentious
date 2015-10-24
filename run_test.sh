#!/bin/sh

git add .
gem build ruby-ddt.gemspec
gem install ddt-0.0.1.gem
ruby test/test_generator.rb
