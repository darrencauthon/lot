require_relative '../../spec_helper'

describe Lot::Event do

  describe "publish" do

    let(:event) { random_string }

    let(:the_key)   { random_string }
    let(:the_value) { random_string }
    let(:data)      { { the_key => the_value } }

    describe "and two event subscribers are defined" do

      let(:subscriber1) { Object.new }
      let(:subscriber2) { Object.new }

      before do
        Lot::EventHandler.stubs(:types).returns [subscriber1, subscriber2]
      end

      describe "and both subscribed to the event" do

        before do
          subscriber1.stubs(:subscribed?).returns true
          subscriber2.stubs(:subscribed?).returns true
        end

        it "should fire each of the subscribers" do
          subscriber1.expects(:fire).with event, data
          subscriber2.expects(:fire).with event, data

          Lot::Event.publish event, data
        end

      end

      describe "and only one is subscribed to the event" do

        before do
          subscriber1.stubs(:subscribed?).returns true
          subscriber2.stubs(:subscribed?).returns false
        end

        it "should fire each of the subscribers" do
          subscriber1.expects(:fire).with event, data
          Lot::Event.publish event, data
        end

      end

    end

  end

end
