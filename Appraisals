# frozen-string-literal: true

appraise 'rails-5.0' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 50', platforms: %i[jruby]
  gem 'rails', '~> 5.0.0'
  gem 'sqlite3', '~> 1.3.6', platforms: %i[mri mingw x64_mingw]
end

appraise 'rails-5.1' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 51', platforms: %i[jruby]
  gem 'rails', '~> 5.1.0'
  gem 'sqlite3', '~> 1.3', '>= 1.3.6', platforms: %i[mri mingw x64_mingw]
end

appraise 'rails-5.2' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 52', platforms: %i[jruby]
  gem 'rails', '~> 5.2.0'
  gem 'sqlite3', '~> 1.3', '>= 1.3.6', platforms: %i[mri mingw x64_mingw]
end

appraise 'rails-6.0' do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 60', platforms: %i[jruby]
  gem 'rails', '~> 6.0.0'
  gem 'sqlite3', '~> 1.4', platforms: %i[mri mingw x64_mingw]
end

unless RUBY_ENGINE == 'jruby'
  appraise 'rails-6.1' do
    gem 'rails', '~> 6.1.0.rc1'
    gem 'sqlite3', '~> 1.4', platforms: %i[mri mingw x64_mingw]
  end
end
