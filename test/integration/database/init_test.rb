require 'test_helper'
require 'ivybridgedaddy/commands/database/init'

class IvyBridgeDaddy::Commands::Database::InitTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_database_help_init_command_successfully
    output = `bundle exec ivy-bridge-daddy database help init`
    expected_output = <<-OUT
Usage:
  ivy-bridge-daddy database init [PATH]

Options:
  -h, [--help], [--no-help]  # Display usage information

Initialize database
    OUT

    assert_equal expected_output, output
  end
end
