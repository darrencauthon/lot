module Lot

  class EventHandler

    attr_accessor :event, :data, :saver

    def self.inherited type
      @types ||= []
      @types << type
    end

    def self.types
      @types || []
    end

    def self.subscribed? event, data, saver
      false
    end

    def self.all_subscribed_to event, data, saver
      types.select { |x| x.subscribed? event, data, saver }
    end

    def self.fire event, data, saver
      self.new.tap do |e|
        e.event = event
        e.data  = data
        e.saver = saver
      end.execute
    end

  end

end
