module Lot

  module Event

    def self.publish event, data, saver
      Lot::EventHandler
        .all_subscribed_to(event, data, saver)
        .each { |t| t.fire event, data, saver }
    end

  end

end
