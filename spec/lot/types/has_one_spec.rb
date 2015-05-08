require_relative '../../spec_helper'

class Astronaut < Lot::Base
  def self.default_schema
    [
      { name: :name,                  type: :string },
      { name: :favorite_planet,       type: :has_one },
      { name: :least_favorite_planet, type: :has_one },
    ]
  end
end

class Planet < Lot::Base
end

describe "has one" do

  let(:saver) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before { setup_db }

  describe "serializing" do

    it "should include the uuid" do
      planet = Planet.new
      result = Lot::HasOne.serialize planet
      planet.record_uuid.nil?.must_equal false
      result = HashWithIndifferentAccess.new(JSON.parse(result))
      result[:record_uuid].must_equal planet.record_uuid
    end

    it "should return the name" do
      name = random_string
      planet = Planet.new.tap { |x| x.name = name }
      result = Lot::HasOne.serialize planet
      result = HashWithIndifferentAccess.new(JSON.parse(result))
      result[:name].must_equal name
    end

    it "should return the id" do
      id = random_string
      planet = Planet.new.tap { |x| x.id = id }
      result = Lot::HasOne.serialize planet
      result = HashWithIndifferentAccess.new(JSON.parse(result))
      result[:id].must_equal id
    end

    describe "returning the type of the class" do
      describe "one example" do
        it "should return the type of the class" do
          planet = Planet.new
          result = Lot::HasOne.serialize planet
          result = HashWithIndifferentAccess.new(JSON.parse(result))
          result[:record_type].must_equal 'planet'
        end
      end

      describe "another example" do
        it "should return the type of the class" do
          astronaut = Astronaut.new
          result = Lot::HasOne.serialize astronaut
          result = HashWithIndifferentAccess.new(JSON.parse(result))
          result[:record_type].must_equal 'astronaut'
        end
      end
    end

    describe "given nil" do
      it "should return nil" do
        Lot::HasOne.serialize(nil).must_be_same_as nil
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
        result = Lot::HasOne.deserialize input
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
        result = Lot::HasOne.deserialize input
        result.id.must_equal astronaut.id
        result.name.must_equal astronaut.name
        result.is_a?(Astronaut).must_equal true
      end

    end

    describe "given nil" do
      it "should return nil" do
        Lot::HasOne.deserialize(nil).must_be_same_as nil
      end
    end

  end

  describe "typing this into the system" do

    let(:earth) { Planet.new.tap { |p| p.name = "Earth"; p.save_by(saver) } }
    let(:mars)  { Planet.new.tap { |p| p.name = "Mars"; p.save_by(saver) } }

    let(:mary)  { Astronaut.new.tap { |a| a.name = "Mary"; a.save_by(saver) } }
    let(:john)  { Astronaut.new.tap { |a| a.name = "John"; a.save_by(saver) } }

    before do
      Astronaut.delete_all
      Planet.delete_all
      [earth, mars]
    end

    it "should allow me to designate a favorite planet" do
      mary.favorite_planet = earth
      mary.save_by saver

      Astronaut.find(mary.id).favorite_planet.tap do |p|
        p.class.must_equal Planet
        p.id.must_equal earth.id
      end
    end

    it "should allow me to designate multiple things" do
      john.favorite_planet = mars
      john.least_favorite_planet = earth
      john.save_by saver

      Astronaut.find(john.id).favorite_planet.tap do |p|
        p.class.must_equal Planet
        p.id.must_equal mars.id
      end

      Astronaut.find(john.id).least_favorite_planet.tap do |p|
        p.class.must_equal Planet
        p.id.must_equal earth.id
      end
    end

  end

end
