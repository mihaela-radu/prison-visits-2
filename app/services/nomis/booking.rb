module Nomis
  class Booking
    include NonPersistedModel

    attribute :visit_id, String
  end
end
