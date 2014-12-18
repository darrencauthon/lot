require_relative '../spec_helper'

class Elephant < Lot::Base
end

describe Lot::Base do

  before do
    Elephant.delete_all
    setup_db
  end

  describe "creating the data store underneath the object" do

    it "should create a base class for the object in question" do
      eval("ElephantBase") # this will throw if it does not exist
    end
    
    it "should be an active record base" do
      eval("ElephantBase").new.is_a?(ActiveRecord::Base).must_equal true
    end

  end

  describe "using this for crud operations" do
    it "should allow me to save records" do
      elephant = Elephant.new
      elephant.save
      Elephant.count.must_equal 1
    end

    it "should let me save attributes about the record" do
      name = SecureRandom.uuid
      elephant = Elephant.new
      elephant.name = name
      elephant.save

      elephant = Elephant.find elephant.id
      elephant.name.must_equal name
    end

    it "should let me save multiple, different attributes about the record" do
      city, state = SecureRandom.uuid, SecureRandom.uuid
      elephant = Elephant.new
      elephant.city  = city
      elephant.state = state
      elephant.save

      elephant = Elephant.find elephant.id
      elephant.city.must_equal city
      elephant.state.must_equal state
    end
  end

end
