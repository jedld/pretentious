#!/bin/sh

git add .
gem build pretentious.gemspec
gem install pretentious-0.0.6.gem
ruby test/test_generator.rb
