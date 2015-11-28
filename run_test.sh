#!/bin/sh

git add .
gem build pretentious.gemspec
gem install pretentious-0.0.9.gem
ruby test/test_generator.rb
