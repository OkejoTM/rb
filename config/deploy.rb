# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "propimo"
set :repo_url, "git@gitlab.com:gvterechov/propimo.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "master"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/propimo/website"

set :rbenv_type, :user
# set :rbenv_ruby, '2.7.5'

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))

set :rails_env, 'production'

set :format, :pretty
# set :log_level, :debug

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, 'NODE_ENV' => 'production'

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service propimo restart"
    end
  end

  before :deploy, :create_deploy_sign_file do
    on roles(:app), in: :sequence do
      execute 'touch /home/propimo/website/current/deploy'
    end
  end

  # before :starting, :run_tests do
  #   puts 'Running tests before deploy'
  #
  #   unless system 'rspec'
  #     puts 'Tests are failed deployment is being aborted'
  #     exit
  #   end
  # end

  after :finishing, 'deploy:restart'
end
