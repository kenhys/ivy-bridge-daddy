require 'test_helper'
require 'ivybridgedaddy/commands/recommend'

class IvyBridgeDaddy::Commands::RecommendTest < Test::Unit::TestCase
  def test_executes_ivybridgedaddy_help_recommend_command_successfully
    output = `bundle exec ivy-bridge-daddyhelp recommend`
    expected_output = <<-OUT
Usage:
  ivy-bridge-daddy recommend [OPTION]

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    assert_equal expected_output, output
  end
end
