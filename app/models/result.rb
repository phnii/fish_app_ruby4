class Result < ApplicationRecord
  belongs_to :trip
  has_one_attached :image

  validates :fish_name, format: { with: /\A^([ァ-ン]|ー)+\z/, message: "is invalid. Use full-width katakana characters"}

  def was_attached?
    self.image.attached?
  end

  def self.search(keyword)
    if keyword != ''
      Result.where("fish_name = '#{keyword}'")
    end
  end
end
