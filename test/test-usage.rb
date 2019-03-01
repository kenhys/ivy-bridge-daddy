class TestUsage < Test::Unit::TestCase

  def test_no_arguments
    output = `bundle exec ivy-bridge-daddy`
    expected = <<-EOS
Commands:
  ivy-bridge-daddy config [SUBCOMMAND]    # Initialize configuration
  ivy-bridge-daddy crawl SITE [TASK]      # Command description...
  ivy-bridge-daddy database [SUBCOMMAND]  # Initialize database
  ivy-bridge-daddy help [COMMAND]         # Describe available commands or one specific command
  ivy-bridge-daddy version                # ivy-bridge-daddy version

EOS
    assert_equal(expected, output)
  end
end
