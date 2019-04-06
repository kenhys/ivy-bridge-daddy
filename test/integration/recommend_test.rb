require 'test_helper'
require 'ivybridgedaddy/commands/recommend'

class Ivybridgedaddy::Commands::RecommendTest < Minitest::Test
  def test_executes_ivybridgedaddy_help_recommend_command_successfully
    output = `ivybridgedaddy help recommend`
    expected_output = <<-OUT
Usage:
  ivybridgedaddy recommend [OPTION]

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    assert_equal expected_output, output
  end
end
