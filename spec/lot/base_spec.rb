require_relative '../spec_helper'

class Elephant < Lot::Base
end

class Giraffe < Lot::Base
end

class Lion < Lot::Base
  self.set_table_name_to 'lions'
end

types_for_lot_base_testing = [Elephant, Giraffe]

describe Lot::Base do

  let(:instigator) { Struct.new(:record_type, :id, :record_uuid).new(SecureRandom.uuid, rand(100), SecureRandom.uuid) }

  types_for_lot_base_testing.each do |type|

    describe "working with data objects (#{type})" do

      before do
        setup_db
        type.delete_all
        Lot::DeletedRecord.delete_all
        Lot::RecordHistory.delete_all
      end

      describe "getting the record type" do
        it "should record the underscored type" do
          type.new.record_type.must_equal type.to_s.underscore
        end

        it "should check for the exact underscore value (faking to verify the _)" do
          record = type.new
          record.stubs(:class).returns "The Rain In Spain"
          record.record_type.must_equal 'the_rain_in_spain'
        end
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
          3.times { type.new.save_by(instigator) }
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
          record.save_by(instigator)
          type.count.must_equal 1
        end

        it "should let me save attributes about the record" do
          name = SecureRandom.uuid
          record = type.new
          record.name = name
          record.save_by(instigator)

          record = type.find record.id
          record.name.must_equal name
        end

        it "should let me save multiple, different attributes about the record" do
          city, state = SecureRandom.uuid, SecureRandom.uuid
          record = type.new
          record.city  = city
          record.state = state
          record.save_by(instigator)

          record = type.find record.id
          record.city.must_equal city
          record.state.must_equal state
        end

        describe "creating without a instigator" do
          it "should let me create a record without a creator" do
            name = SecureRandom.uuid
            record = type.new
            record.name = name
            record.create!

            record = type.find record.id
            record.name.must_equal name
          end
        end

        describe "deleting records" do
          it "should let me delete records" do
            record = type.new
            record.save_by(instigator)

            record = type.find record.id
            record.delete_by instigator
            type.all.count.must_equal 0
          end

          it "should keep any non-deleted records" do
            record = type.new
            record.save_by(instigator)

            others = [1, 2].map { |_| type.new.tap { |x| x.save_by instigator } }

            record = type.find record.id
            record.delete_by instigator
            type.all.count.must_equal 2

            type.find(others[0].id).nil?.must_equal false
            type.find(others[1].id).nil?.must_equal false
          end

          it "should keep a history of the deleted record" do
            record = type.new.tap { |x| x.save_by instigator }
            record.delete_by instigator
            Lot::DeletedRecord.count.must_equal 1
          end

          it "should retain the record type" do
            record = type.new.tap { |x| x.save_by instigator }
            record.delete_by instigator
            Lot::DeletedRecord.first.record_type.must_equal record.record_type
          end

          it "should retain the record id, as a string" do
            record = type.new.tap { |x| x.save_by instigator }
            record.delete_by instigator
            Lot::DeletedRecord.first.record_id.must_equal record.id.to_s
          end

          it "should retain the record uuid, as a string" do
            record = type.new.tap { |x| x.save_by instigator }
            record.delete_by instigator
            Lot::DeletedRecord.first.record_uuid.must_equal record.record_uuid.to_s
          end

          it "should retain record data" do
            name = SecureRandom.uuid
            record = type.new.tap { |x| x.save_by instigator }
            record.name = name
            record.delete_by instigator
            JSON.parse(Lot::DeletedRecord.first.data)['name'].must_equal record.name
          end
        end

        describe "eventing" do

          describe "creating a record" do

            it "should fire a record created event" do
              name = random_string

              record = type.new
              record.name = name

              t = type
              Lot::Event.expects(:publish).with do |e, d, i|
                e.must_equal "#{type.to_s}: Created"
                d['record_id'].must_equal t.all.first.id
                d['name'].must_equal name
                i.must_be_same_as instigator
              end

              record.save_by(instigator)
            end

          end

          describe "updating a record" do

            it "should fire a record updated event" do
              record = type.new
              record.name = random_string
              record.save_by instigator

              name = random_string
              Lot::Event.expects(:publish).with("#{type.to_s}: Updated", { 'record_id' => record.id, 'name' => name }, instigator)
              record.name = name
              record.save_by(instigator)
            end

          end

          describe "firing an event with a !" do
            it "should if fire an event" do
              record = type.new
              record.save_by instigator

              Lot::Event.expects(:publish).with("#{type.to_s}: Do something", { 'record_id' => record.id }, nil)
              record.do_something!
            end

            it "should should track the instigator passed as the first argument" do
              record = type.new
              record.save_by instigator

              Lot::Event.expects(:publish).with("#{type.to_s}: Do something", { 'record_id' => record.id }, instigator)
              record.do_something! instigator
            end

            it "should allow both an instigator and event data" do
              key, value = random_string, random_string
              record = type.new
              record.save_by instigator

              Lot::Event.expects(:publish).with("#{type.to_s}: Do something", { 'record_id' => record.id, key => value }, instigator)
              record.do_something! instigator, { key => value }
            end

            it "should allow just the event data to be passed" do
              key, value = random_string, random_string
              record = type.new
              record.save_by instigator

              Lot::Event.expects(:publish).with("#{type.to_s}: Do something", { 'record_id' => record.id, key => value }, nil)
              record.do_something!( { key => value } )
            end
          end

        end

      end

      describe "trying to save without a instigator" do
        it "should not save the record" do
          record = type.new
          record.save_by nil
          type.count.must_equal 0
        end

        it "should return false" do
          record = type.new
          record.save_by(nil).must_equal false
        end
      end

      describe "tracking changed fields" do
        it "should default a new object to having no dirty properties" do
          record = type.new
          record.dirty_properties.count.must_equal 0
        end

        it "should track the properties that are changed for an object" do
          field = SecureRandom.uuid.to_sym

          record = type.new
          record.send("#{field}=", SecureRandom.uuid)

          record.dirty_properties.count.must_equal 1
          record.dirty_properties.first.must_be_same_as field
        end

        it "should keep a unique set of changed properties, if a property is changed twice" do
          field = SecureRandom.uuid.to_sym

          record = type.new
          record.send("#{field}=", SecureRandom.uuid)
          record.send("#{field}=", SecureRandom.uuid)

          record.dirty_properties.count.must_equal 1
          record.dirty_properties.first.must_be_same_as field
        end

        it "should remove the dirty fields after the save" do
          field = SecureRandom.uuid.to_sym

          record = type.new
          record.send("#{field}=", SecureRandom.uuid)
          record.save_by(instigator)

          record.dirty_properties.count.must_equal 0
        end

        it "should not mark a field as dirty if the change is not actually a change" do
          field = SecureRandom.uuid.to_sym
          value = SecureRandom.uuid

          record = type.new
          record.send("#{field}=", value)
          record.save_by(instigator)

          record.send("#{field}=", value)

          record.dirty_properties.count.must_equal 0
        end
      end

      describe "the record uuid" do

        it "should set a unique record id" do
          id = SecureRandom.uuid
          SecureRandom.stubs(:uuid).returns id
          record = type.new
          record.record_uuid.must_equal id
        end

        it "should persist the record uuid" do
          record = type.new
          record.save_by(instigator)
          id          = record.id
          record_uuid = record.record_uuid

          record = type.find id
          record.record_uuid.must_equal record_uuid
        end

      end

      describe "the history" do

        it "should default a record to having no history" do
          record = type.new
          record.history.count.must_equal 0
        end

        it "should stamp a history of the record being created" do
          record = type.new
          record.save_by(instigator)

          record.history.count.must_equal 1
        end

        describe "the historical record" do

          let(:key)   { SecureRandom.uuid }
          let(:the_value) { SecureRandom.uuid }

          let(:record) do
            type.new.tap do |r|
              r.send("#{key}=".to_sym, the_value)
              r.save_by(instigator)
            end
          end

          it "should include the record type" do
            record.history[0].record_type.must_equal type.to_s.underscore
          end

          it "should include the id" do
            record.history[0].record_id.must_equal record.id
          end

          it "should include the record uuid" do
            record.history[0].record_uuid.must_equal record.record_uuid
          end

          it "should include the old data" do
            record.history[0].old_data[key].nil?.must_equal true
          end

          it "should include the new data" do
            record.history[0].new_data[key].must_equal the_value
          end

          describe "stamping more history" do
            let(:new_value) { SecureRandom.uuid }

            before do
              record.send("#{key}=".to_sym, new_value)
              record.save_by(instigator)
            end

            it "should include the old data" do
              record.history[1].old_data[key].must_equal the_value
            end

            it "should include the new data" do
              record.history[1].new_data[key].must_equal new_value
            end

          end

          describe "stamping who made the change" do

            it "should include instigator's id" do
              record.history[0].instigator_id.must_equal instigator.id
            end

            it "should include instigator's uuid" do
              record.history[0].instigator_uuid.must_equal instigator.record_uuid
            end

            it "should include instigator's type" do
              record.history[0].instigator_type.must_equal instigator.record_type
            end

          end


          describe "histories were created for other objects" do
            before do
              Lot::RecordHistory.create(record_type: record.type.to_s.underscore)
              Lot::RecordHistory.create(record_id:   record.id)
              Lot::RecordHistory.create(record_uuid: record.record_uuid)
            end

            it "should only return the history for the current record" do
              record.history.count.must_equal 1
              record.history.first.tap do |history|
                history.record_type.must_equal type.to_s.underscore
                history.record_id.must_equal record.id
                history.record_uuid.must_equal record.record_uuid
              end
            end
          end

        end

      end

      describe "the default schema" do
        it "should be nil, relying on the base class to reimplement it" do
          type.default_schema.nil?.must_equal true
        end
      end

      describe "the schema" do

        before do
          # reset the schema
          type.class_eval { @schema = nil }
        end

        describe "starting from nothing" do

          describe "there is no default schema" do
            before { type.stubs(:default_schema).returns nil }
            it "should default to an empty schema" do
              type.schema.count.must_equal 0
            end
          end

          describe "there is a default schema" do
            let(:default) { [{}] }
            before { type.stubs(:default_schema).returns default }
            it "should return the default" do
              type.schema.must_be_same_as default
            end
          end

          it "should add fields to the schema when they are used for the first time" do
            field = SecureRandom.uuid.split('-')[0].to_sym

            record = type.new
            record.send("#{field}=".to_sym, SecureRandom.uuid)
            record.save_by(instigator)

            type.schema.count.must_equal 1
            type.schema[0][:name].must_equal field
          end

          it "should only add the field once" do
            field = SecureRandom.uuid.split('-')[0].to_sym

            record = type.new
            record.send("#{field}=".to_sym, SecureRandom.uuid)
            record.send("#{field}=".to_sym, SecureRandom.uuid)
            record.save_by(instigator)

            type.schema.count.must_equal 1
          end

          it "should add multiple fields" do
            field1 = SecureRandom.uuid.split('-')[0].to_sym
            field2 = SecureRandom.uuid.split('-')[0].to_sym

            record = type.new
            record.send("#{field1}=".to_sym, SecureRandom.uuid)
            record.send("#{field2}=".to_sym, SecureRandom.uuid)
            record.save_by(instigator)

            type.schema.count.must_equal 2
            type.schema[0][:name].must_equal field1
            type.schema[1][:name].must_equal field2
          end

          it "should default fields to string" do
            field = SecureRandom.uuid.split('-')[0].to_sym

            record = type.new
            record.send("#{field}=".to_sym, SecureRandom.uuid)
            record.save_by(instigator)

            type.schema.count.must_equal 1
            type.schema[0][:type].must_equal :string
          end

        end

        describe "building a schema ahead of time" do

          it "should let me add fields to the object" do
            field = SecureRandom.uuid.split('-')[0].to_sym

            type.schema << { name: field, type: :string }

            type.schema.count.must_equal 1
            type.schema[0][:name].must_equal field
          end

          it "should let me set a new type" do
            field = SecureRandom.uuid.split('-')[0].to_sym

            type.schema << { name: field, type: :something_else }

            type.schema.count.must_equal 1
            type.schema[0][:type].must_equal :something_else
          end

          describe "defining how to serialize this type" do

            let(:field) { SecureRandom.uuid.split('-')[0].to_sym }

            before do
              Lot.types[:something_else] = {
                                             serialize:   -> (v) { ".#{v}" },
                                             deserialize: -> (v) { "#{v}." },
                                           }
              type.schema << { name: field, type: :something_else }
            end

            it "should run the value through the deserializer before returning it" do
              type.new.send(field).must_equal '.'
            end

            it "should run the value through the serializer when setting it" do
              record = type.new
              value  = SecureRandom.uuid
              record.send("#{field}=".to_sym, value)
              record.save_by(instigator)

              record = type.find record.id
              record.send(field).must_equal ".#{value}."
            end

          end

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
      first_record = first_type.new.save_by(instigator)
      second_record = second_type.new.save_by(instigator)

      first_type.count.must_equal 1
      second_type.count.must_equal 1
    end

    it "should update the record after it has been created" do
      record = first_type.new
      record.save_by(instigator)
      record.name = 'something'
      record.save_by(instigator)

      first_type.count.must_equal 1

      record = first_type.find record.id
      record.name.must_equal 'something'
      record
    end

    it "should return the result of the save operation" do
      expected = Object.new
      record = first_type.new
      eval("#{first_type}Base").any_instance.stubs(:save).returns expected
      record.save_by(instigator).must_be_same_as expected
    end

  end

  describe "all query" do

    let(:first_type)  { types_for_lot_base_testing[0] }
    let(:second_type) { types_for_lot_base_testing[1] }

    before do
      setup_db
      types_for_lot_base_testing.each { |t| t.delete_all }
    end

    it "should return a query based on the record type" do
      first_record = first_type.new.save_by(instigator)
      second_record = second_type.new.save_by(instigator)

      first_type.the_data_source_query.count.must_equal 1
      second_type.the_data_source_query.count.must_equal 1
    end

    it "should return the active record objects" do
      first_record = first_type.new.save_by(instigator)
      second_record = second_type.new.save_by(instigator)

      first_type.the_data_source_query.first.is_a?(ActiveRecord::Base).must_equal true
      second_type.the_data_source_query.first.is_a?(ActiveRecord::Base).must_equal true
    end

  end

  describe "all" do

    let(:first_type)  { types_for_lot_base_testing[0] }
    let(:second_type) { types_for_lot_base_testing[1] }

    before do
      setup_db
      types_for_lot_base_testing.each { |t| t.delete_all }
    end

    it "should return the appropriate records" do
      first_record = first_type.new.save_by(instigator)
      second_record = second_type.new.save_by(instigator)

      first_type.all.count.must_equal 1
      second_type.all.count.must_equal 1
    end

    it "should return the records for each" do
      first_record = first_type.new
      first_record.save_by(instigator)

      second_record = second_type.new
      second_record.save_by(instigator)

      first_type.all.first.id.must_equal first_record.id
      second_type.all.first.id.must_equal second_record.id
    end

  end

  describe "changing the base table" do

    before do
      Lion.delete_all
      Elephant.delete_all
      Giraffe.delete_all
    end

    it "should allow table names to be changed" do
      Lion.table_name.must_equal 'lions'
    end

    it "should allow the saving of data to different tables" do
      Lion.new.save_by(instigator)
      LionBase.connection.execute("SELECT Count(*) FROM lions")[0]['count'].to_i.must_equal 1
      Elephant.new.save_by(instigator)
      Giraffe.new.save_by(instigator)
      LionBase.connection.execute("SELECT Count(*) FROM records")[0]['count'].to_i.must_equal 2
    end

    it "should default the table name to records" do
      Elephant.table_name.must_equal 'records' 
    end

  end

  describe "inherited" do

    let(:type) { Object.new }

    before do
      Lot::Base.instance_eval { @types = nil }
      type.stubs(:set_table_name_to).with 'records'
    end

    it "should set the default table name to records" do
      type.expects(:set_table_name_to).with 'records'
      Lot::Base.inherited type
    end

    it "should start on a list of types" do
      Lot::Base.inherited type
      Lot::Base.types.count.must_equal 1
      Lot::Base.types.first.must_be_same_as type
    end

    it "should continue to build on that list as new types come in" do
      another_type = Object.new
      another_type.stubs :set_table_name_to
      Lot::Base.inherited type
      Lot::Base.inherited another_type

      Lot::Base.types.count.must_equal 2
      Lot::Base.types.include?(another_type).must_equal true
      Lot::Base.types.include?(type).must_equal true
    end

  end

  describe "types" do

    before { Lot::Base.instance_eval { @types = nil } }

    it "should default to an empty list" do
      Lot::Base.types.count.must_equal 0
      Lot::Base.types.is_a?(Array).must_equal true
    end

  end

end
