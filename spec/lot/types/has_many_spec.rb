require_relative '../../spec_helper'

class Kingdom < Lot::Base
  def self.default_schema
    [
      { name: :name,    type: :string },
      { name: :phylums, type: :has_many },
    ]
  end
end

class Phylum < Lot::Base
end

describe "has many" do

  let(:saver) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  before { setup_db }

  describe "typing this into the system" do

    let(:animal)    { Kingdom.new.tap { |p| p.name = "Animal";    p.save_by(saver) } }
    let(:vegetable) { Kingdom.new.tap { |p| p.name = "Vegetable"; p.save_by(saver) } }

    let(:kinorhyncha)  { Phylum.new.tap { |p| p.name = "Kinorhyncha";  p.save_by(saver) } }
    let(:hemichordata) { Phylum.new.tap { |p| p.name = "Hemichordata"; p.save_by(saver) } }
    let(:ctenophora)   { Phylum.new.tap { |p| p.name = "Ctenophora";   p.save_by(saver) } }

    before do
      Kingdom.delete_all
      Phylum.delete_all
    end

    it "should allow me to designate multiple things" do
      animal.phylums = [kinorhyncha, hemichordata, ctenophora]
      animal.save_by saver

      the_animal = Kingdom.find(animal.id)
      the_animal.phylums.tap do |phylums|
        phylums.each { |x| x.class.must_equal Phylum }

        phylums.map { |x| x.name }.tap do |names|
          names.include?('Kinorhyncha').must_equal true
          names.include?('Hemichordata').must_equal true
          names.include?('Ctenophora').must_equal true
        end
      end
    end

  end

end
