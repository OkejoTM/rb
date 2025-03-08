# Автоматически обновляет аннотации после каждого запуска миграций
task_names = %w[db:migrate db:rollback]
task_names.each do |task_name|
  Rake::Task[task_name].enhance do
    %x{bundle exec annotate} if Rails.env.development?
  end
end
