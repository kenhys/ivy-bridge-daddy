require 'test_helper'
require 'ivybridgedaddy/commands/config/init'

class IvyBridgeDaddy::Commands::Config::InitTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_config_help_init_command_successfully
    output = `bundle exec ivy-bridge-daddy config help init`
    expected_output = <<-OUT
Usage:
  ivy-bridge-daddy config init [PATH]

Options:
  -h, [--help], [--no-help]  # Display usage information

Initialize configuration
    OUT

    assert_equal expected_output, output
  end
end
