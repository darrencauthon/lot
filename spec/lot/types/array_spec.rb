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

  let(:instigator) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before do
    setup_db
    ArrayLover.delete_all
  end
  
  it "should default to an empty array" do
    lover = ArrayLover.new
    lover.things.count.must_equal 0
    lover.things.is_a?(Array).must_equal true
  end

  it "should allow me to save arrays of strings" do
    lover = ArrayLover.new
    lover.things = ['a', 'b']
    lover.save_by instigator

    lover = ArrayLover.find lover.id
    lover.things.count.must_equal 2
    lover.things.include?('a').must_equal true
    lover.things.include?('b').must_equal true
  end

  it "should allow me to save arrays of numbers" do
    lover = ArrayLover.new
    lover.things = [1, 2]
    lover.save_by instigator

    lover = ArrayLover.find lover.id
    lover.things.count.must_equal 2
    lover.things.include?(1).must_equal true
    lover.things.include?(2).must_equal true
  end

  it "should allow me to save hashes" do
    lover = ArrayLover.new
    lover.things = [ { name: 'a' }, { name: 'b' } ]
    lover.save_by instigator

    lover = ArrayLover.find lover.id
    lover.things.count.must_equal 2
    lover.things.select { |x| x['name'] == 'a' }.count.must_equal 1
    lover.things.select { |x| x['name'] == 'b' }.count.must_equal 1
  end

  it "should allow me to save hashes, and return them as hash with indifferent access" do
    lover = ArrayLover.new
    lover.things = [ { name: 'a' }, { name: 'b' } ]
    lover.save_by instigator

    lover = ArrayLover.find lover.id
    lover.things.count.must_equal 2
    lover.things.select { |x| x['name'] == 'a' }.count.must_equal 1
    lover.things.select { |x| x['name'] == 'b' }.count.must_equal 1
    lover.things.select { |x| x[:name] == 'a' }.count.must_equal 1
    lover.things.select { |x| x[:name] == 'b' }.count.must_equal 1
  end
end
