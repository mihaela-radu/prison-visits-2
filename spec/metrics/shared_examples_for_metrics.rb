RSpec.shared_examples 'create rejections without dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  def luna_visits_without_dates
    make_visits(luna)
  end

  def mars_visits_without_dates
    make_visits(mars)
  end

  def make_visits(prison)
    create_list(:booked_visit, 6, prison: prison)
    nc = create(:rejected_visit, prison: prison)
    na = create(:rejected_visit, prison: prison)
    su = create(:rejected_visit, prison: prison)
    vb = create(:rejected_visit, prison: prison)
    create(:rejection, visit: nc, reason: 'no_allowance')
    create(:rejection, visit: na, reason: 'no_allowance')
    create(:rejection, visit: su, reason: 'slot_unavailable')
    create(:rejection, visit: vb, reason: 'visitor_banned')
  end
end

RSpec.shared_examples 'create rejections with dates' do
  let(:luna_estate) { create(:estate, finder_slug: 'luna') }
  let(:mars_estate) { create(:estate, finder_slug: 'mars') }
  let(:luna) { create(:prison, name: 'Lunar Penal Colony', estate: luna_estate) }
  let(:mars) { create(:prison, name: 'Martian Penal Colony', estate: mars_estate) }

  def luna_visits_with_dates
    make_visits(luna)
  end

  def mars_visits_with_dates
    make_visits(mars)
  end

  def make_visits(prison)
    create_list(:booked_visit, 5, created_at: Time.zone.local(2016, 2, 1), prison: prison)

    nc = create(:rejected_visit, prison: prison, created_at: Time.zone.local(2016, 2, 1))
    na = create(:rejected_visit, prison: prison, created_at: Time.zone.local(2016, 2, 2))
    su = create(:rejected_visit, prison: prison, created_at: Time.zone.local(2016, 2, 3))
    vb = create(:rejected_visit, prison: prison, created_at: Time.zone.local(2016, 2, 4))
    no_adult = create(:rejected_visit, prison: prison, created_at: Time.zone.local(2016, 2, 4))
    create(:rejection, visit: nc, created_at: Time.zone.local(2016, 2, 1))
    create(:rejection, visit: na, created_at: Time.zone.local(2016, 2, 2))
    create(:rejection, visit: su, reason: 'slot_unavailable', created_at: Time.zone.local(2016, 2, 3))
    create(:rejection, visit: vb, reason: 'visitor_banned', created_at: Time.zone.local(2016, 2, 4))
    create(:rejection, visit: no_adult, reason: 'no_adult', created_at: Time.zone.local(2016, 2, 4))
  end
end

RSpec.shared_examples 'create visits without dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  let!(:luna_visits_without_dates) do
    make_visits(luna)
  end

  let!(:mars_visits_without_dates) do
    make_visits(mars)
  end

  def make_visits(prison)
    [:visit, :booked_visit, :rejected_visit,
     :cancelled_visit, :withdrawn_visit].each do |visit_type|
      create(visit_type, prison: prison)
    end
  end
end

RSpec.shared_examples 'create visits with dates' do
  # Most of the time these don't matter.  I've included them here to make it
  # easier to target the TDs in the metrics table.
  let(:luna_estate) { create(:estate, finder_slug: 'luna') }
  let(:mars_estate) { create(:estate, finder_slug: 'mars') }
  let(:luna) { create(:prison, name: 'Lunar Penal Colony', estate: luna_estate) }
  let(:mars) { create(:prison, name: 'Martian Penal Colony', estate: mars_estate) }

  let(:luna_visits_with_dates) do
    make_visits(luna)
  end

  let(:mars_visits_with_dates) do
    make_visits(mars)
  end

  # Let will not work here as the object is memoized.
  def luna_visit
    create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
  end

  def mars_visit
    create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: mars)
  end

  def request_a_visit_that_remains_overdue
    create(:visit, created_at: Time.zone.local(2016, 1, 1), prison: luna)
  end

  def book_a_luna_visit_late
    travel_to Time.zone.local(2016, 2, 5) do
      luna_visit.accept!
    end
  end

  def book_a_luna_visit_on_time
    travel_to Time.zone.local(2016, 2, 2) do
      luna_visit.accept!
    end
  end

  def cancel_a_luna_visit_late
    lv = luna_visit
    travel_to Time.zone.local(2016, 2, 5) do
      lv.accept!
      lv.cancel!
    end
  end

  def cancel_a_luna_visit_on_time
    lv = luna_visit
    travel_to Time.zone.local(2016, 2, 2) do
      lv.accept!
      lv.cancel!
    end
  end

  def withdraw_a_luna_visit_late
    travel_to Time.zone.local(2016, 2, 5) do
      luna_visit.cancel!
    end
  end

  def withdraw_a_luna_visit_on_time
    travel_to Time.zone.local(2016, 2, 2) do
      luna_visit.cancel!
    end
  end

  def reject_a_luna_visit_late
    travel_to Time.zone.local(2016, 2, 5) do
      luna_visit.reject!
    end
  end

  def reject_a_luna_visit_on_time
    travel_to Time.zone.local(2016, 2, 2) do
      luna_visit.reject!
    end
  end

  def book_a_mars_visit_late
    travel_to Time.zone.local(2016, 2, 5) do
      mars_visit.accept!
    end
  end

  def book_a_mars_visit_on_time
    travel_to Time.zone.local(2016, 2, 2) do
      mars_visit.accept!
    end
  end

  def reject_a_mars_visit_late
    travel_to Time.zone.local(2016, 2, 5) do
      mars_visit.reject!
    end
  end

  def reject_a_mars_visit_on_time
    travel_to Time.zone.local(2016, 2, 2) do
      mars_visit.reject!
    end
  end

  def make_visits(prison)
    create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:visit, created_at: Time.zone.local(2016, 2, 8), prison: prison)

    create(:booked_visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:booked_visit, created_at: Time.zone.local(2016, 2, 8), prison: prison)

    create(:rejected_visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:rejected_visit, created_at: Time.zone.local(2016, 2, 15), prison: prison)

    # Due to percularities of isoyear, this will show up as the last week of 2015
    # in the calendar week count.
    create(:cancelled_visit, created_at: Time.zone.local(2016, 1, 1), prison: prison)
  end
end

RSpec.shared_examples 'create and process visits timed by seconds' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  before do
    [luna, mars].each do |prison|
      visits = []
      travel_to Time.zone.local(2016, 3, 1, 13, 0, 0) do
        visits = create_list(:visit, 10, prison: prison)
      end

      visits.each_with_index do |visit, i|
        seconds = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55].fetch(i)
        travel_to Time.zone.local(2016, 3, 1, 13, 0, seconds) do
          visit.accept!
        end
      end
    end
  end
end

RSpec.shared_examples 'create and process visits with dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  let(:luna_visits_with_dates) do
    make_visits(luna)
  end

  let(:mars_visits_with_dates) do
    make_visits(mars)
  end

  def make_visits(prison)
    [1, 8, 15].each do |day|
      visits = create_list(:visit, 3, created_at: Time.zone.local(2016, 2, day), prison: prison)

      visits.each_with_index do |visit, index|
        days = [3, 5, 9].fetch(index)
        processed_on = visit.created_at + days.day
        travel_to processed_on do
          visit.accept!
        end
      end
    end
  end
end
