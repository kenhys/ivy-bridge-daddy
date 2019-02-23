require 'test_helper'
require 'ivybridgedaddy/commands/config'

class Ivybridgedaddy::Commands::ConfigTest < Minitest::Test
  def test_executes_ivybridgedaddy_help_config_command_successfully
    output = `ivybridgedaddy help config`
    expected_output = <<-OUT
Commands:
    OUT

    assert_equal expected_output, output
  end
end
