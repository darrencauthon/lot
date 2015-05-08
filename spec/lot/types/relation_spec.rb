require_relative '../../spec_helper'

class Astronaut < Lot::Base
  def self.default_schema
    [
      { name: :name,            type: :string },
      { name: :favorite_planet, type: :relation, is: :planet },
    ]
  end
end

class Planet < Lot::Base
end

describe "relation" do

  describe "serializing" do

    it "should include the uuid" do
      planet = Planet.new
      result = Lot::Relation.serialize planet
      planet.record_uuid.nil?.must_equal false
      result[:record_uuid].must_equal planet.record_uuid
    end

    it "should return the name" do
      name = random_string
      planet = Planet.new.tap { |x| x.name = name }
      result = Lot::Relation.serialize planet
      result[:name].must_equal name
    end

    it "should return the id" do
      id = random_string
      planet = Planet.new.tap { |x| x.id = id }
      result = Lot::Relation.serialize planet
      result[:id].must_equal id
    end

    describe "returning the type of the class" do
      describe "one example" do
        it "should return the type of the class" do
          planet = Planet.new
          result = Lot::Relation.serialize planet
          result[:record_type].must_equal 'planet'
        end
      end

      describe "another example" do
        it "should return the type of the class" do
          astronaut = Astronaut.new
          result = Lot::Relation.serialize astronaut
          result[:record_type].must_equal 'astronaut'
        end
      end
    end

  end

end
