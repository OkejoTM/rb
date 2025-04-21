class Parsers::RealEstateParserLogger < Logger
  require 'fileutils'

  def initialize(log_dir, parser, stats)
    @stats = stats

    @log = RealEstateParserLog.create(
      real_estate_parser_id: parser.id,
      status: 'in_progress',
      created_properties_count: 0,
      updated_properties_count: 0,
      deleted_properties_count: 0,
      error_properties_count: 0,
      total_properties_count: 0,
    )

    @log_file = File.join(File.join(log_dir, parser.name.downcase.gsub(' ', '_')), "log_#{@log.id}.txt")
    create_log_directory(File.join(log_dir, parser.name.downcase.gsub(' ', '_')))
    @logger = Logger.new(@log_file)
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    log_start_time
  end

  def fatal(message)
    @logger.fatal(message)
    update_log_from_stats
  end

  def error(message)
    @logger.error(message)
    update_log_from_stats
  end

  def info(message)
    @logger.info(message)
    update_log_from_stats
  end

  def warn(message)
    @logger.warn(message)
  end

  def debug(message)
    @logger.debug(message)
  end

  def unknown(message)
    @logger.unknown(message)
  end

  private
    def create_log_directory(log_dir)
      FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)
    end

    def log_start_time
      @logger.info("Parsing started #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
    end

    def update_log_from_stats
      return unless @stats.changed
      @log.update(@stats.to_h.merge(updated_at: Time.now))
      @stats.reset_changed
    end
end
