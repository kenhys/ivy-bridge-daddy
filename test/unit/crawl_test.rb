require 'test_helper'
require 'ivybridgedaddy/commands/crawl'
#require 'webmock/test_unit'

class IvyBridgeDaddy::Commands::CrawlTest < Test::Unit::TestCase
  def test_executes_crawl_command_successfully
    output = StringIO.new
    site,option = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Crawl.new(site,option, options)

    command.execute(output: output)

    assert_equal "", output.string
  end

  class PcKoubouTest < self

    def setup
      options = Selenium::WebDriver::Firefox::Options.new
      options.add_argument("-headless")

      @client = Selenium::WebDriver::Remote::Http::Default.new
      @client.read_timeout = 120
      @client.open_timeout = 120

      host = "localhost"
      proxy = Selenium::WebDriver::Proxy.new(
        :http     => host,
        :ftp      => host,
        :ssl      => host,
        :no_proxy => nil
      )
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(:proxy => proxy)
      #driver = Selenium::WebDriver.for :chrome ,:desired_capabilities => caps
      #@driver = Selenium::WebDriver.for :firefox, :http_client => @client, :desired_capabilities => caps, options: options
      @driver = Selenium::WebDriver.for :firefox, :http_client => @client, options: options
    end

    class ModelExtractorTest < self
      def test_price
        path = fixture_file_path("container-item.html")
        p path
        #stub_request(:any, "127.0.0.1").to_return(body: open(path), status: 200)

        @driver.get(path)
        element = @driver.find_element(:class_name => "container-item")
        model = IvyBridgeDaddy::Crawler::PcKoubou::ModelExtractor.new(element)
        model.parse
      end
    end
  end
end
