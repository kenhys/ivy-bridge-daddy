require 'test_helper'
require 'ivybridgedaddy/commands/recommend'

class Ivybridgedaddy::Commands::RecommendTest < Minitest::Test
  def test_executes_recommend_command_successfully
    output = StringIO.new
    option = nil
    options = {}
    command = Ivybridgedaddy::Commands::Recommend.new(option, options)

    command.execute(output: output)

    assert_equal "OK\n", output.string
  end
end
