# frozen-string-literal: true

appraise 'rails-6.0' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 60', platforms: %i[jruby]
  gem 'rails', '~> 6.0.0'
  gem 'sqlite3', '~> 1.4', platforms: %i[mri mingw x64_mingw]
end

appraise 'rails-6.1' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 61', platforms: %i[jruby]
  gem 'rails', '~> 6.1.0'
  gem 'sqlite3', '~> 1.4', platforms: %i[mri mingw x64_mingw]
end

unless RUBY_ENGINE == 'jruby'
  appraise 'rails-7.0' do
    gem 'rails', '~> 7.0.0'
    gem 'sqlite3', '~> 1.4', platforms: %i[mri mingw x64_mingw]
  end
end
