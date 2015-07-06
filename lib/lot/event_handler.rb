module Lot
  class EventHandler
    def self.inherited type
      @types ||= []
      @types << type
    end

    def self.types
      @types || []
    end

    def self.subscribed? event, data
      false
    end

    def self.fire event, data
      new.execute event, data
    end
  end
end
