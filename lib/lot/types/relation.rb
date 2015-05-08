module Lot
  module Relation
    def self.serialize input
      return nil unless input
      {
        record_uuid: input.record_uuid,
        id:          input.id,
        name:        input.name,
        record_type: input.record_type
      }.to_json
    end

    def self.deserialize input
      return nil unless input
      input = JSON.parse(input) if input.is_a?(String)
      input = HashWithIndifferentAccess.new input
      record_type = input[:record_type]
      type        = Lot.class_from_record_type(record_type)
      id          = input[:id]
      type.find id
    end
  end
end
