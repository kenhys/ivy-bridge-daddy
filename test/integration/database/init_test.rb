require 'test_helper'
require 'ivybridgedaddy/commands/database/init'

class IvyBridgeDaddy::Commands::Database::InitTest < Minitest::Test
  def test_executes_ivybridgedaddy_database_help_init_command_successfully
    output = `ivy-bridge-daddy database help init`
    expect_output = <<-OUT
Usage:
  ivy-bridge-daddy init [PATH]

Options:
  -h, [--help], [--no-help]  # Display usage information

Initialize database
    OUT

    assert_equal expected_output, output
  end
end
