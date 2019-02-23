require 'test_helper'
require 'ivybridgedaddy/commands/database'

class IvyBridgeDaddy::Commands::DatabaseTest < Minitest::Test
  def test_executes_ivybridgedaddy_help_database_command_successfully
    output = `ivy-bridge-daddy help database`
    expected_output = <<-OUT
Commands:
    OUT

    assert_equal expected_output, output
  end
end
