require 'test_helper'
require 'ivybridgedaddy/commands/crawl'

class IvyBridgeDaddy::Commands::CrawlTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_help_crawl_command_successfully
    output = `bundle exec ivy-bridge-daddy help crawl`
    expected_output = <<-OUT
Usage:
  ivy-bridge-daddy crawl SITE [TASK]

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    assert_equal expected_output, output
  end
end
