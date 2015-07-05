module Lot

  module Event

    def self.publish event, data
      Lot::EventHandler.types
        .select { |t| t.subscribed? event, data }
        .each   { |t| t.fire event, data }
    end

  end

end
