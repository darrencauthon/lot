module Lot

  module HasMany

    def self.serialize records
      return nil unless records
      records.map do |input|
        {
          record_uuid: input.record_uuid,
          id:          input.id,
          name:        input.name,
          record_type: input.record_type
        }
      end.to_json
    end

    def self.deserialize input
      return nil unless input
      input = standardize_the_serialized_input input
      input.map { |x| Lot.class_from_record_type(x[:record_type]).find x[:id] }
    end

    def self.definition
      {
        has_many: {
                    deserialize: ->(i) { self.deserialize i },
                    serialize:   ->(i) { self.serialize i },
                  }
      }
    end

    class << self

      private

      def standardize_the_serialized_input input
        input = JSON.parse(input) if input.is_a?(String)
        input.map { |x| HashWithIndifferentAccess.new x }
      end
    end

  end

end
