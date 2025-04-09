ENV["ELASTICSEARCH_URL"] = "http://localhost:9200,http://localhost:9201"

Searchkick.client = Elasticsearch::Client.new(hosts: ["127.0.0.1:9200", "127.0.0.1:9201"],
                                              retry_on_failure: true,
                                              transport_options:
                                                  { request: { timeout: 250 } })
