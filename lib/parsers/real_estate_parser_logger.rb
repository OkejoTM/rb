class Parsers::RealEstateParserLogger < Logger
  require 'fileutils'

  def initialize(log_dir, parser)
    @log = RealEstateParserLog.create(real_estate_parser_id: parser.id, status: 'in_progress')
    @log_file = File.join(File.join(log_dir, parser.name.downcase.gsub(' ', '_')), "log_#{@log.id}.txt")
    create_log_directory(File.join(log_dir, parser.name.downcase.gsub(' ', '_')))
    @logger = Logger.new(@log_file)
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    log_start_time
  end

  def fatal(message)
    @logger.fatal(message)
    @log.update(status: 'unsuccess')
  end

  def error(message)
    @logger.error(message)
    @log.update(status: 'unsuccess')
  end

  def info(message)
    @logger.info(message)

    match = message.match(/(?:New properties|Новых недвижимостей): (\d+).*?(?:Existed properties|Существующих недвижимостей): (\d+)/)
    if match
      @log.update(created_properties_count: match[1] , updated_properties_count: match[2])
    end

    match = message.match(/(?:Deleted properties|Удаленных недвижимостей): (\d+)/)
    if match
      @log.update(deleted_properties_count: match[1])
    end

    match = message.match(/Parsing finished|Парсинг завершен/)
    if match
      unless @log.status == 'unsuccess'
        @log.update(status: 'success')
      end
      @log.update(updated_at: Time.now.strftime('%Y-%m-%d %H:%M:%S'))
    end
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
end
