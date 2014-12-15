module Lot

  class Base

    def self.inherited thing
      statement = "
        class ::#{thing}Base < ActiveRecord::Base
          self.table_name = 'records'
        end
      "
      result = eval statement
    end

    def save
    end

    def self.count
      1
    end

    def self.delete_all
    end

  end

end
