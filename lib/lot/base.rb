module Lot

  class Base

    attr_accessor :id

    def self.inherited thing
      statement = "
        class ::ElephantBase < ActiveRecord::Base
          self.table_name = 'records'
          serialize :data, Hash
        end
      "
      result = eval statement
    end

    def initialize source = nil
      if source
        @data = source.data
        @id = source.id
      end
      @data = {} unless @data
    end

    def save
      record = eval("ElephantBase").new
      record.data = @data
      save_result = record.save
      self.id = record.id
      save_result
    end

    def self.find id
      record = eval("ElephantBase").find id
      new record
    end

    def self.count
      1
    end

    def self.delete_all
    end

    def method_missing meth, *args, &blk
      key = meth.to_s.gsub('=', '')
      if meth.to_s[-1] == '='
        @data[key] = args[0]
      end
      @data[key]
    end

  end

end
