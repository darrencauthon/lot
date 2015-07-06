require_relative '../../spec_helper'

class OhAndAnotherThing < Lot::Base
end

describe Lot::EventHandler do

  before do
    setup_db
    Lot::EventHandler.instance_eval { @types = nil }
  end

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
      Lot::EventHandler.subscribed?(nil, nil, nil).must_equal false
    end

  end

  describe "fire" do

    let(:the_event) { Object.new }
    let(:the_data)  { Object.new }
    let(:instigator)     { Object.new }

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
        something.instigator.must_be_same_as instigator
      end
      Something.fire the_event, the_data, instigator
    end
  end

  describe "subject" do

    before do
      OhAndAnotherThing.new.save!
      OhAndAnotherThing.new.save!
      OhAndAnotherThing.new.save!
    end

    describe "a subject can be found matching the record_id and event name in the system" do

      it "should look up the subject" do
        subject = OhAndAnotherThing.new
        subject.save!

        handler = Lot::EventHandler.new
        handler.data  = { 'record_id' => subject.id }
        handler.event = 'OhAndAnotherThing: Jump up and down'

        handler.subject.id.must_equal subject.id
      end

    end

  end

  describe "task" do

    before do
      OhAndAnotherThing.new.save!
      OhAndAnotherThing.new.save!
      OhAndAnotherThing.new.save!
    end

    it "should look up the task" do
      task = random_string

      subject = OhAndAnotherThing.new
      subject.save!

      handler = Lot::EventHandler.new
      handler.data  = { 'record_id' => subject.id }
      handler.event = "OhAndAnotherThing: #{task}"

      handler.task.must_equal task
    end

  end

end
