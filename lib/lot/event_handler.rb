module Lot

  class EventHandler

    attr_accessor :event, :data, :instigator

    def self.inherited type
      @types ||= []
      @types << type
    end

    def self.types
      @types || []
    end

    def self.subscribed? event, data, instigator
      false
    end

    def self.all_subscribed_to event, data, instigator
      types.select { |x| x.subscribed? event, data, instigator }
    end

    def self.fire event, data, instigator
      self.new.tap do |e|
        e.event      = event
        e.data       = data
        e.instigator = instigator
      end.execute
    end

  end

end
