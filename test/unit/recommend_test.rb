require 'test_helper'
require 'ivybridgedaddy/commands/recommend'

class IvyBridgeDaddy::Commands::RecommendTest < Test::Unit::TestCase
  def test_executes_recommend_command_successfully
    output = StringIO.new
    option = nil
    options = {}
    command = IvyBridgeDaddy::Commands::Recommend.new(option, options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
