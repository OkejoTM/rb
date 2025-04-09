if Rails.env.development? #|| Rails.env.test?
  Pry.hooks.add_hook(:before_eval, :reload_everything) { reload!(true); }
end
