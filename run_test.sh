#!/bin/sh

git add .
gem build pretentious.gemspec
gem install pretentious-0.1.0.gem
ruby test/test_generator.rb
