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

  let(:saver) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before { setup_db }

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

  describe "deserializing" do

    describe "looking up the original" do

      it "should lookup the related item" do
        name   = random_string
        planet = Planet.new
        planet.name = name
        planet.save_by saver

        input = { record_type: :planet, id: planet.id }
        result = Lot::Relation.deserialize input
        result.id.must_equal planet.id
        result.name.must_equal planet.name
        result.is_a?(Planet).must_equal true
      end

      it "should lookup the related item, for another type" do
        name   = random_string
        astronaut = Astronaut.new
        astronaut.name = name
        astronaut.save_by saver

        input = { record_type: :astronaut, id: astronaut.id }
        result = Lot::Relation.deserialize input
        result.id.must_equal astronaut.id
        result.name.must_equal astronaut.name
        result.is_a?(Astronaut).must_equal true
      end

    end

  end

end
