# frozen_string_literal: true

class NeedPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || user_in_office?
  end

  def create?
    user.admin? || (user_in_office? && user.scheduler?)
  end

  def new?
    user.admin? || user.scheduler?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def permitted_attributes_for_create
    permitted_attributes | %i[start_at expected_duration]
  end

  def permitted_attributes
    [:office_id, :race_id, :preferred_language_id, :number_of_children, age_range_ids: []]
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(office_id: user.office_ids)
      end
    end
  end

  private

  def user_in_office?
    record.office&.user_ids&.include? user.id
  end
end
