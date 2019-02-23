require 'test_helper'
require 'ivybridgedaddy/commands/config'

class IvyBridgeDaddy::Commands::ConfigTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_help_config_command_successfully
    output = `bundle exec ivy-bridge-daddy help config`
    expected_output = <<-OUT
Commands:
  ivy-bridge-daddy config help [COMMAND]  # Describe subcommands or one specific subcommand
  ivy-bridge-daddy config init [PATH]     # Initialize configuration

    OUT

    assert_equal expected_output, output
  end
end
