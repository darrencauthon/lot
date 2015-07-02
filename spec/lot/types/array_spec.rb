require_relative '../../spec_helper'

class ArrayLover < Lot::Base
  def self.default_schema
    [
      { name: :name,   type: :string },
      { name: :things, type: :array },
    ]
  end
end

describe "array" do

  let(:saver) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before do
    setup_db
    ArrayLover.delete_all
  end
  
  it "should default to an empty array" do
    lover = ArrayLover.new
    lover.things.count.must_equal 0
    lover.things.is_a?(Array).must_equal true
  end

end
