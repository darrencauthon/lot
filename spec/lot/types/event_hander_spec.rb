require_relative '../../spec_helper'

describe Lot::EventHandler do

  before { Lot::EventHandler.instance_eval { @types = nil } }

  describe "types" do

    it "should return inherited types" do
      inherited = Object.new
      Lot::EventHandler.inherited inherited

      Lot::EventHandler.types.count.must_equal 1
      Lot::EventHandler.types.first.must_be_same_as inherited
    end

    it "should default to nothing" do
      Lot::EventHandler.types.count.must_equal 0
    end

  end

end
