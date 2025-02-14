# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth
#  and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::PeopleController
  extend ActiveSupport::Concern

  included do
    before_save :set_manager_notice
    after_save :set_manager_flash
  end

  def set_manager_flash
    flash[:notice] = [flash[:notice],
                      @manager_notice].flatten
  end

  def set_manager_notice
    new_managers = entry.people_managers.select { |pm| pm.new_record? }.map(&:manager)
    destroyed_managers = entry.people_managers
                              .select { |pm| pm.marked_for_destruction? }.map(&:manager)
    new_manageds = entry.people_manageds.select { |pm| pm.new_record? }.map(&:managed)
    destroyed_manageds = entry.people_manageds
                              .select { |pm| pm.marked_for_destruction? }.map(&:managed)

    @manager_notice = [['new_managers', new_managers],
                       ['destroyed_managers', destroyed_managers],
                       ['new_manageds', new_manageds],
                       ['destroyed_manageds', destroyed_manageds]].map do |translation_key, people|
                         next if people.blank?

                         t(".flash.#{translation_key}",
                           labels: people.map(&:person_name).join(', '),
                           count: people.size)
                       end.compact
  end

  def permitted_params
    permitted = super
    if cannot?(:change_managers, entry)
      permitted = permitted.except(:people_managers_attributes)
    end
    permitted[:people_manageds_attributes]&.keep_if do |index, attrs|
      managed = extract_managed(attrs)
      managed.present? && can?(:change_managers, managed)
    end
    permitted
  end

  def accessible_people_managers_attributes
    permitted
  end

  private

  def extract_managed(attrs)
    return Person.find_by(id: attrs[:managed_id]) if attrs[:managed_id].present?
    return PeopleManager.find_by(id: attrs[:id]).managed if attrs[:id].present?
    nil
  end
end
