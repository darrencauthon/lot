require 'base64'

module Lot

  module Object

    def self.serialize input
      return nil unless input
      Base64.encode64(Marshal.dump(input))
    end

    def self.deserialize input
      return nil unless input
      Marshal.load(Base64.decode64(input))
    end

    def self.definition
      {
        object: {
                  deserialize: ->(i) { self.deserialize i },
                  serialize:   ->(i) { self.serialize i },
                }
      }
    end

  end

end
