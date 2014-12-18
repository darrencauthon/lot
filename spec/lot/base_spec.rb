require_relative '../spec_helper'

class Elephant < Lot::Base
end

class Giraffe < Lot::Base
end

describe Lot::Base do

  [Elephant, Giraffe].each do |type|

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

    end

  end

end
