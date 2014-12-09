class Meetup < ActiveRecord::Base
  has_many :rsvps
  has_many :users, through: :rsvps

  validates :name,
    presence: true
  validates :description,
    presence: true
  validates :location,
    presence: true
end
