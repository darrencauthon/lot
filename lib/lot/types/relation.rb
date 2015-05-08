module Lot
  module Relation
    def self.serialize input
      { record_uuid: input.record_uuid, name: input.name }
    end
  end
end
