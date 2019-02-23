require 'test_helper'
require 'ivybridgedaddy/commands/config/init'

class IvyBridgeDaddy::Commands::Config::InitTest < Test::Unit::TestCase
  def test_executes_config_init_command_successfully
    output = StringIO.new
    path = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Config::Init.new(path, options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
