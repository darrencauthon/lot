module Lot

  module Array

    def self.serialize input
    end

    def self.deserialize input
      []
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
