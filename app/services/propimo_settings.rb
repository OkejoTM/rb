class PropimoSettings
  class << self
    def fetch(key)
      @settings ||= Settings.new(ActiveRecord::Base.connection)
      @settings[key]
    end

    def set(key, value)
      @settings ||= Settings.new(ActiveRecord::Base.connection)
      @settings[key] = value
    end

    def on?(key)
      fetch(key).to_s.downcase == 'true'
    end
  end
end
