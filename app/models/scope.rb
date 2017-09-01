# frozen_string_literal: true

class Scope < ApplicationRecord
  belongs_to :scope_type
  belongs_to :parent,
             class_name: "Scope",
             inverse_of: :children,
             counter_cache: :children_count,
             optional: true

  has_many :children,
           foreign_key: "parent_id",
           class_name: "Scope",
           inverse_of: :parent

  before_validation :update_part_of, on: :update

  validates :name, :code, presence: true
  validates :code, uniqueness: true
  validate :forbid_cycles

  after_create_commit :create_part_of

  scope :leafs, -> { where children_count: 0 }

  # Scope to return only the top level scopes.
  #
  # Returns an ActiveRecord::Relation.
  def self.top_level
    where(parent_id: nil)
  end

  def self.local
    find_by(code: Settings.regional.local_code)
  end

  def descendants
    Scope.where("? = ANY (part_of)", id)
  end

  def not_descendants
    Scope.where.not("? = ANY (part_of)", id)
  end

  # Gets the scopes from the part_of list in descending order (first the top level scope, last itself)
  #
  # Returns an array of Scope objects
  def part_of_scopes(root = nil)
    Scope.where(id: part_of - (root ? root.part_of : [])).sort { |s1, s2| part_of.index(s2.id) <=> part_of.index(s1.id) }
  end

  private

  def forbid_cycles
    errors.add(:parent_id, :cycle_detected) if parent && parent.part_of.include?(id)
  end

  def create_part_of
    build_part_of
    save if changed?
  end

  def update_part_of
    build_part_of
  end

  def build_part_of
    if parent
      part_of.clear.append(id).concat(parent.reload.part_of)
    else
      part_of.clear.append(id)
    end
  end
end
