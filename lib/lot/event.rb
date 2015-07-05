module Lot
  module Event
    def self.publish event, data
      Lot::EventHandler.types.each do |type|
        type.fire event, data
      end
    end
  end
end
