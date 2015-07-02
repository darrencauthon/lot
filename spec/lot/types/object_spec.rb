require_relative '../../spec_helper'

class ObjectLover < Lot::Base
  def self.default_schema
    [
      { name: :name,  type: :string },
      { name: :thing, type: :object },
    ]
  end
end

describe "object" do

  let(:saver) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before do
    setup_db
    ObjectLover.delete_all
  end
  
  it "should default to nil" do
    lover = ObjectLover.new
    lover.thing.nil?.must_equal true
  end

  it "should allow me to save simple values" do
    ['1', nil, 2].each do |value|
      lover = ObjectLover.new
      lover.thing = value
      lover.save_by saver
      ObjectLover.find(lover.id).thing.must_equal value
    end
  end

end
