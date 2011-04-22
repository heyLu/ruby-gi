require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the GIMarshallingTests namespace.
describe "GIMarshallingTests" do
  before do
    GirFFI.setup :GIMarshallingTests
  end

  describe "BoxedStruct" do
    it "is created with #new" do
      bx = GIMarshallingTests::BoxedStruct.new
      assert_instance_of GIMarshallingTests::BoxedStruct, bx
    end

    it "has the method #inv" do
      bx = GIMarshallingTests::BoxedStruct.new
      bx[:long_] = 42
      bx.inv
      pass
    end
  end
end
