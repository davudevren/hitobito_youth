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

  def assert_manager_is_not_managed
    errors.add(:base, :manager_and_managed_the_same) if manager.id == managed.id
  end
end
