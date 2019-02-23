require 'test_helper'
require 'ivybridgedaddy/commands/database'

class IvyBridgeDaddy::Commands::DatabaseTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_help_database_command_successfully
    output = `bundle exec ivy-bridge-daddy help database`
    expected_output = <<-OUT
Commands:
  ivy-bridge-daddy database help [COMMAND]  # Describe subcommands or one specific subcommand
  ivy-bridge-daddy database init [PATH]     # Initialize database

OUT

    assert_equal expected_output, output
  end
end
