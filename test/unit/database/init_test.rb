require 'test_helper'
require 'ivybridgedaddy/commands/database/init'

class IvyBridgeDaddy::Commands::Database::InitTest < Test::Unit::TestCase
  def test_executes_database_init_command_successfully
    output = StringIO.new
    path = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Database::Init.new(path, options)

    command.execute(output: output)

    assert_equal "", output.string
  end
end
