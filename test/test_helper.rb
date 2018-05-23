$VERBOSE = nil # for hide ruby warnings

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', %i[telegram_accounts users])

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
end
