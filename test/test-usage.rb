class TestUsage < Test::Unit::TestCase

  def test_no_arguments
    output = `bundle exec ivy-bridge-daddy`
    expected = <<-EOS
Commands:
  ivy-bridge-daddy help [COMMAND]  # Describe available commands or one specific command
  ivy-bridge-daddy version         # ivy-bridge-daddy version

EOS
    assert_equal(expected, output)
  end
end
