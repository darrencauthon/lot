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

  describe "subscribed?" do

    it "should return false by default" do
      Lot::EventHandler.subscribed?(nil, nil).must_equal false
    end

  end

  describe "fire" do

    let(:the_event) { Object.new }
    let(:the_data)  { Object.new }

    before { eval "class Something < Lot::EventHandler; end" }

    after do
      Lot::EventHandler.instance_eval { @types = nil }
    end

    it "should call execute with the event and data set" do
      something = Something.new
      Something.stubs(:new).returns something

      something.expects(:execute).with do
        something.event.must_be_same_as the_event
        something.data.must_be_same_as the_data
      end
      Something.fire the_event, the_data
    end
  end

end
