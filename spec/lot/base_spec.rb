require_relative '../spec_helper'

class Elephant < Lot::Base
end

class Giraffe < Lot::Base
end

types_for_lot_base_testing = [Elephant, Giraffe]

describe Lot::Base do

  types_for_lot_base_testing.each do |type|

    describe "working with data objects (#{type})" do

      before do
        setup_db
        type.delete_all
      end

      describe "creating the data store underneath the object" do

        it "should create a base class for the object in question" do
          eval("#{type}Base") # this will throw if it does not exist
        end
        
        it "should be an active record base" do
          eval("#{type}Base").new.is_a?(ActiveRecord::Base).must_equal true
        end

      end

      describe "delete all" do
        it "should delete all of the records" do
          base_type = eval("#{type}Base")
          3.times { base_type.create }
          type.delete_all
          base_type.count.must_equal 0
        end
      end

      describe "counting" do
        it "should return the number of records" do
          base_type = eval("#{type}Base")
          base_type.delete_all
          3.times { type.new.save }
          type.count.must_equal 3
        end
      end

      describe "finding a record" do
        it "should return the record in question" do
          base_type = eval("#{type}Base")
          base_type.delete_all
          records = (0...3).to_a.map { base_type.create }
          records.each { |r| type.find(r.id).id.must_equal r.id }
        end
      end

      describe "using this for crud operations" do

        it "should allow me to save records" do
          record = type.new
          record.save
          type.count.must_equal 1
        end

        it "should let me save attributes about the record" do
          name = SecureRandom.uuid
          record = type.new
          record.name = name
          record.save

          record = type.find record.id
          record.name.must_equal name
        end

        it "should let me save multiple, different attributes about the record" do
          city, state = SecureRandom.uuid, SecureRandom.uuid
          record = type.new
          record.city  = city
          record.state = state
          record.save

          record = type.find record.id
          record.city.must_equal city
          record.state.must_equal state
        end

      end

      describe "the schema" do

        before do
          # reset the schema
          type.class_eval { @schema = nil }
        end

        it "should default to an empty schema" do
          type.schema.count.must_equal 0
        end

        it "should add fields to the schema when they are used for the first time" do
          field = SecureRandom.uuid.split('-')[0].to_sym

          record = type.new
          record.send("#{field}=".to_sym, SecureRandom.uuid)
          record.save

          type.schema.count.must_equal 1
          type.schema[0][:name].must_equal field
        end

        it "should add multiple fields" do
          field1 = SecureRandom.uuid.split('-')[0].to_sym
          field2 = SecureRandom.uuid.split('-')[0].to_sym

          record = type.new
          record.send("#{field1}=".to_sym, SecureRandom.uuid)
          record.send("#{field2}=".to_sym, SecureRandom.uuid)
          record.save

          type.schema.count.must_equal 2
          type.schema[0][:name].must_equal field1
          type.schema[1][:name].must_equal field2
        end

        it "should default fields to string" do
          field = SecureRandom.uuid.split('-')[0].to_sym

          record = type.new
          record.send("#{field}=".to_sym, SecureRandom.uuid)
          record.save

          type.schema.count.must_equal 1
          type.schema[0][:type].must_equal :string
        end

      end

    end

  end

  describe "saving records of each type" do

    let(:first_type)  { types_for_lot_base_testing[0] }
    let(:second_type) { types_for_lot_base_testing[1] }

    before do
      setup_db
      types_for_lot_base_testing.each { |t| t.delete_all }
    end

    it "should keep the counts separate" do
      first_record = first_type.new.save
      second_record = second_type.new.save

      first_type.count.must_equal 1
      second_type.count.must_equal 1
    end

  end

end
