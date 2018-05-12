# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "activemodel"
gem "activesupport"

group :test do
  gem "rspec"
  gem "factory_bot", "~> 4.0"
end

group :development, :test do
  gem "pry"
  gem "pry-byebug"
end
