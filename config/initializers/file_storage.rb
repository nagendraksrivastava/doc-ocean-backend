Paperclip::Attachment.default_options.merge!({
  path: "#{Rails.root}/public/system/:class/:attachment/:id_partition/:style/:filename"
})
