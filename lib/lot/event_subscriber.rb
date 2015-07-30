module Lot

  class EventSubscriber

    attr_accessor :event, :data, :instigator

    def subject
      segments = event.split ':'
      segments.pop
      type = segments.join(':')
      type.constantize.find data['record_id']
    end

    def task
      event.split(':').pop.strip
    end

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
