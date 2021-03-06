module Nomis
  class PrisonerDetailedAvailability
    include NonPersistedModel

    attribute :dates, Array[PrisonerDateAvailability], coercer: lambda { |dates|
      dates.map { |d| PrisonerDateAvailability.new(d) }
    }

    def self.build(attrs)
      new_attrs = attrs.each_with_object(dates: []) do |(date, info), list|
        availability = info.deep_dup
        availability['date'] = date
        list[:dates] << availability
      end

      new(new_attrs)
    end

    def available?(slot)
      error_messages_for_slot(slot).empty?
    end

    def error_messages_for_slot(slot)
      sentry_debugging_context(slot)
      availability_for(slot).unavailable_reasons(slot)
    end

  private

    def availability_for(slot)
      dates.find do |date_availability|
        date_availability.date == slot.to_date
      end
    end

    # :nocov:
    def sentry_debugging_context(slot)
      Raven.extra_context(
        slot: slot,
        dates: dates
      )
    end
  end
end
