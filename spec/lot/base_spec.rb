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
  end

end
