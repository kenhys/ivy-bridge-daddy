require 'test_helper'
require 'ivybridgedaddy/commands/crawl'

class IvyBridgeDaddy::Commands::CrawlTest < Test::Unit::TestCase
  def test_executes_crawl_command_successfully
    output = StringIO.new
    site,option = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Crawl.new(site,option, options)

    command.execute(output: output)

    assert_equal "", output.string
  end
end
