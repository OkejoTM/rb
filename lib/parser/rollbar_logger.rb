class Parser::RollbarLogger < Logger
  def error(progname = nil, &block)
    super(progname, &block)
    Rollbar.error(progname)
  end
end
