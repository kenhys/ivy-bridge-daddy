require 'test_helper'
require 'ivybridgedaddy/commands/config/init'

class Ivybridgedaddy::Commands::Config::InitTest < Minitest::Test
  def test_executes_ivybridgedaddy_config_help_init_command_successfully
    output = `ivybridgedaddy config help init`
    expect_output = <<-OUT
Usage:
  ivybridgedaddy init PATH

Options:
  -h, [--help], [--no-help]  # Display usage information

Initialize configuration
    OUT

    assert_equal expected_output, output
  end
end
