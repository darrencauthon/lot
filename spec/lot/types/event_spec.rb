require_relative '../../spec_helper'

describe Lot::Event do

  describe "publish" do

    let(:event) { random_string }

    let(:the_key)   { random_string }
    let(:the_value) { random_string }
    let(:instigator) { Object.new }
    let(:data)      { { the_key => the_value } }

    describe "and two event subscribers are defined" do

      let(:subscriber1) { Object.new }
      let(:subscriber2) { Object.new }

      before do
        Lot::EventSubscriber.stubs(:types).returns [subscriber1, subscriber2]
      end

      describe "and both subscribed to the event" do

        before do
          subscriber1.stubs(:subscribed?).with(event, data, instigator).returns true
          subscriber2.stubs(:subscribed?).with(event, data, instigator).returns true
        end

        it "should fire each of the subscribers" do
          subscriber1.expects(:fire).with event, data, instigator
          subscriber2.expects(:fire).with event, data, instigator

          Lot::Event.publish event, data, instigator
        end

      end

      describe "and only one is subscribed to the event" do

        before do
          subscriber1.stubs(:subscribed?).with(event, data, instigator).returns true
          subscriber2.stubs(:subscribed?).with(event, data, instigator).returns false
        end

        it "should fire each of the subscribers" do
          subscriber1.expects(:fire).with event, data, instigator
          Lot::Event.publish event, data, instigator
        end

      end

    end

  end

end
