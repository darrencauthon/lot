module Lot

  module Event

    def self.publish event, data
      Lot::EventHandler
        .all_subscribed_to(event, data)
        .each { |t| t.fire event, data }
    end

  end

end
