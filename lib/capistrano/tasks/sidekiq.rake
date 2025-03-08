# https://github.com/seuros/capistrano-sidekiq/issues/224#issuecomment-525308963
# Почему не стоит использовать гем capistrano-sidekiq:
# https://github.com/mperham/sidekiq/wiki/Deployment#capistrano
# https://www.mikeperham.com/2014/09/22/dont-daemonize-your-daemons/

# systemctl by default logs into
set :sidekiq_roles, -> { :app }
set :sidekiq_systemd_unit_name, "sidekiq"

namespace :sidekiq do
  desc 'Quiet sidekiq (stop fetching new tasks from Redis)'
  task :quiet do
    on roles fetch(:sidekiq_roles) do
      # See: https://github.com/mperham/sidekiq/wiki/Signals#tstp
      execute :systemctl,
              '--user',
              'kill',
              '-s',
              'SIGTSTP',
              fetch(:sidekiq_systemd_unit_name),
              raise_on_non_zero_exit: false
    end
  end

  desc 'Stop sidekiq (graceful shutdown within timeout, put unfinished tasks back to Redis)'
  task :stop do
    on roles fetch(:sidekiq_roles) do
      # See: https://github.com/mperham/sidekiq/wiki/Signals#tstp
      execute :systemctl,
              '--user',
              'kill',
              '-s',
              'SIGTERM',
              fetch(:sidekiq_systemd_unit_name),
              raise_on_non_zero_exit: false
    end
  end

  desc 'Start sidekiq'
  task :start do
    on roles fetch(:sidekiq_roles) do
      execute :systemctl,
              '--user',
              'start',
              fetch(:sidekiq_systemd_unit_name)
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles fetch(:sidekiq_roles) do
      execute :systemctl,
              '--user',
              'restart',
              fetch(:sidekiq_systemd_unit_name)
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:updated', 'sidekiq:stop'
after 'deploy:published', 'sidekiq:start'
after 'deploy:failed', 'sidekiq:restart'
