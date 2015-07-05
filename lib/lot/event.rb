module Lot
  module Event
    def self.publish event, data
      Lot::EventHandler.types.each do |type|
        if type.subscribed?(event, data)
          type.fire event, data
        end
      end
    end
  end
end
