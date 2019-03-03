require 'test_helper'
require 'ivybridgedaddy/commands/search'

class IvyBridgeDaddy::Commands::SearchTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_help_search_command_successfully
    output = `bundle exec ivy-bridge-daddy help search`
    expected_output = <<-OUT
Usage:
  ivy-bridge-daddy search QUERY

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    assert_equal expected_output, output
  end
end
