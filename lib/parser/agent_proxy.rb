module Parser
  class AgentProxy
    attr_reader :agent
    delegate :reset, to: :agent

    def initialize(proxy: nil)
      @agent = create_mechanize_agent(proxy: proxy)
    end

    def load_page(url)
      response = @agent.get(url)
      response = @agent.get(url) if response.blank? # в редких случаях страница загружается только со второй попытки(особенно после agent.reset)

      response = yield(@agent, response) if block_given?
      return response
    rescue Mechanize::ResponseCodeError => e
      if e.response_code.to_i == 418
        sleep 5
        @agent.get(url)
      end
    rescue StandardError => e
      return
    end

    private
      def create_mechanize_agent(proxy: nil)
        return Mechanize.new { |a| a.user_agent_alias = 'Mac Safari' } if proxy.blank?

        agent = Mechanize.new do |a|
          a.user_agent_alias = proxy.user_agent_alias
        end
        agent.set_proxy(proxy.ip, proxy.port, proxy.login, proxy.password)

        agent
      end
  end
end
