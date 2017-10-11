# frozen_string_literal: true

require 'test_helper'
require 'support/calendar_integration_helpers'

module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegrationTest < ActiveSupport::TestCase

      include ::CalendarIntegrationHelpers

      def richard
        @richard ||= gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def microsoft_exchange_email
        'richard@microsoft-exchange.com'
      end

      def setup_mocks_for_synchronization(canned_responses)

        # mock event items
        mock_event_items = []

        canned_responses.each do |canned_response|
          event_item = mock
          event_item.stubs(canned_response)
          mock_event_items << event_item
        end

        # mock folder
        folder = mock
        folder.stubs(:expanded_items).returns(mock_event_items)

        Exchanger::Folder.stubs(:find).returns(folder)
      end

      def setup
        super

        # configure site and person
        activate_microsoft_exchange_calendar_integration(sites(:madrid))
        set_microsoft_exchange_email_account(richard, microsoft_exchange_email)
      end

      def event_attributes
        {
          start: 1.hour.from_now,
          end: 2.hours.from_now,
          id: 'external-id-1',
          subject: 'Event 1',
          sensitivity: 'Normal',
          location: 'Location 1'
        }
      end

      def test_sync_events

        event_1 = event_attributes
        event_2 = {
          id: 'external-id-2',
          sensitivity: 'Private'
        }

        setup_mocks_for_synchronization([event_1, event_2])

        assert_difference 'GobiertoCalendars::Event.count', 1 do
          CalendarIntegration.sync_person_events(richard)
        end

        # event 1 checks

        event = richard.events.find_by(external_id: 'external-id-1')
        assert_equal 'Event 1', event.title
        assert_equal 1, event.locations.size
        assert_equal 'Location 1', event.first_location.name
      end

      def test_sync_events_updates_event_attributes
        
        setup_mocks_for_synchronization([event_attributes])
        CalendarIntegration.sync_person_events(richard)

        # simulate attributes are updated from OWA

        event_1 = event_attributes.merge(
          subject: 'Updated event',
          location: 'Updated location'
        )
        
        setup_mocks_for_synchronization([event_1])
        CalendarIntegration.sync_person_events(richard)

        # assert attributes get updated in Gobierto

        event = richard.events.find_by(external_id: 'external-id-1')

        assert_equal 'Updated event', event.title
        assert_equal 'Updated location', event.first_location.name
        assert_equal 1, event.locations.size
      end

      def test_unreceived_events_are_drafted

        # sync two events

        event_1 = event_attributes
        event_2 = event_attributes.merge(id: 'external-id-2')

        setup_mocks_for_synchronization([event_1, event_2])
        CalendarIntegration.sync_person_events(richard)
        
        event = richard.events.find_by(external_id: 'external-id-1')
        
        assert event.published?

        # sync, only receiving the second event

        setup_mocks_for_synchronization([event_2])
        CalendarIntegration.sync_person_events(richard)

        # check first event is unpublished
        
        event.reload
        refute event.published?
      end

      def test_sync_events_removes_deleted_locations
        
        # syncrhonize event with location

        setup_mocks_for_synchronization([event_attributes])
        CalendarIntegration.sync_person_events(richard)

        event = richard.events.find_by(external_id: 'external-id-1')
        assert_equal 1, event.locations.size

        # simulate location was removed from OWA

        event_1 = event_attributes.merge(location: '')

        setup_mocks_for_synchronization([event_1])
        CalendarIntegration.sync_person_events(richard)

        # assert location is deleted in Gobierto

        event.reload
        assert event.locations.empty?
      end

    end
  end
end