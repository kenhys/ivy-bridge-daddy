require 'test_helper'
require 'ivybridgedaddy/commands/config/init'

class Ivybridgedaddy::Commands::Config::InitTest < Minitest::Test
  def test_executes_config_init_command_successfully
    output = StringIO.new
    path = nil
    options = {}
    command = Ivybridgedaddy::Commands::Config::Init.new(path, options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
