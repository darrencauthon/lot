module Lot

  module HasMany

    def self.serialize records
      records ? records.map { |r| JSON.parse Lot::HasOne.serialize r }.to_json
              : nil
    end

    def self.deserialize input
      return [] unless input
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
