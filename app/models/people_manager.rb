# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class PeopleManager < ActiveRecord::Base
  belongs_to :manager, class_name: 'Person'
  belongs_to :managed, class_name: 'Person'

  validates :manager_id, uniqueness: { scope: :managed_id }
  validate :assert_manager_is_not_managed

  after_create :create_paper_trail_versions_for_create_event
  after_destroy :create_paper_trail_versions_for_destroy_event

  has_paper_trail on: []

  def create_paper_trail_versions_for_create_event
    [manager_id, managed_id].each do |main_id|
      PaperTrail::RecordTrail.new(self).send(:build_version_on_create,
                                             in_after_callback: true).tap do |version|
        version.main_id = main_id
        version.main_type = Person.sti_name

        version.save!
        versions.reset
      end
    end
  end

  def create_paper_trail_versions_for_destroy_event
    [manager_id, managed_id].each do |main_id|
      data = PaperTrail::Events::Destroy.new(self, true).data

      data[:main_id] = main_id
      data[:main_type] = Person.sti_name

      version = self.class.paper_trail.version_class.create(data)

      versions = version
    end
  end

  def assert_manager_is_not_managed
    errors.add(:base, :manager_and_managed_the_same) if manager.id == managed.id
  end
end
