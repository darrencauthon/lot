module Lot

  module Event

    def self.publish event, data, instigator
      Lot::EventHandler
        .all_subscribed_to(event, data, instigator)
        .each { |t| t.fire event, data, instigator }
    end

  end

end
