module Lot
  class EventHandler
    def self.inherited type
      @types ||= []
      @types << type
    end

    def self.types
      @types || []
    end
  end
end
