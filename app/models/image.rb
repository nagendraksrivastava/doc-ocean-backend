class Image < ActiveRecord::Base
  has_attached_file :attachment, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  belongs_to :imageable, polymorphic: true

  validates_attachment :attachment, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  def url(style = nil)
    attachment.url(style.try(:to_sym))
  end
end
