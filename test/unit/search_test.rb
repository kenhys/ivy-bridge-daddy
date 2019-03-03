require 'test_helper'
require 'ivybridgedaddy/commands/search'

class IvyBridgeDaddy::Commands::SearchTest < Test::Unit::TestCase
  def test_executes_search_command_successfully
    output = StringIO.new
    query = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Search.new(query, options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
