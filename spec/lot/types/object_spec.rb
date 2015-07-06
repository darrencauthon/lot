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

  let(:instigator) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

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
      lover.save_by instigator
      ObjectLover.find(lover.id).thing.must_equal value
    end
  end

  it "should allow me to save more complicated objects" do
    arnie = ObjectLover.new
    arnie.save_by instigator

    lover = ObjectLover.new
    lover.thing = arnie
    lover.save_by instigator

    ObjectLover.find(lover.id).thing.is_a?(ObjectLover).must_equal true
    ObjectLover.find(lover.id).thing.id.must_equal arnie.id
  end

end
