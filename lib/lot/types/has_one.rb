module Lot

  module HasOne

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
      input = standardize_the_serialized_input input
      Lot.class_from_record_type(input[:record_type]).find input[:id]
    end

    def self.definition
      {
        has_one: {
                   deserialize: ->(i) { self.deserialize i },
                   serialize:   ->(i) { self.serialize i },
                 }
      }
    end

    class << self

      private

      def standardize_the_serialized_input input
        input = JSON.parse(input) if input.is_a?(String)
        HashWithIndifferentAccess.new input
      end
    end

  end

end
