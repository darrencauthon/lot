module Lot

  class EventHandler

    attr_accessor :event, :data

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

    def self.all_subscribed_to event, data
      types.select { |x| x.subscribed? event, data }
    end

    def self.fire event, data
      self.new.tap do |e|
        e.event = event
        e.data  = data
      end.execute
    end

  end

end
