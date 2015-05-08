module Lot
  module Relation
    def self.serialize input
      {
        record_uuid: input.record_uuid,
        id:          input.id,
        name:        input.name,
        record_type: input.record_type
      }
    end

    def self.deserialize input
      Lot.class_from_record_type(input[:record_type]).find input[:id]
    end
  end
end
