module Lot

  module Array

    def self.serialize input
      input.to_json
    end

    def self.deserialize input
      input ? JSON.parse(input) : []
    end

    def self.definition
      {
        array: {
                 deserialize: ->(i) { self.deserialize i },
                 serialize:   ->(i) { self.serialize i },
               }
      }
    end

  end

end
