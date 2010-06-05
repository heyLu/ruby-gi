require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/gtype'

class HelperGTypeTest < Test::Unit::TestCase
  context "The GObject module" do
    should "have type_init as a public method" do
      assert_contains GObject.public_methods, 'type_init'
    end

    should "not have g_type_init as a public method" do
      assert_does_not_contain GObject.public_methods,
	'g_type_init'
    end

  end
  context "the init method" do
    should "not raise an error" do
      assert_nothing_raised do
	GObject.type_init
      end
    end
  end
end
