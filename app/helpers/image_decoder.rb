class ImageDecoder
  attr_accessor :image_params

  def initialize(image_params)
    @image_params = image_params
  end

  def errors
    @errors ||= []
  end

  def validate?
    if image_params[:name].blank?
      @errors << 'Image name should be present'
    end
    if image_params[:image_content].blank?
      @errors << 'Image content should be present'
    end
    errors.blank?
  end

  def process
    image = validate? && decode_base64

    if errors.present?
      OpenStruct.new(success: false, errors: errors)
    else
      OpenStruct.new(success: true, image: image)
    end
  end

  def decode_base64
    File.open(image_params[:name], "wb") do |file|
      file.write(Base64.decode64(image_params[:image_content]))
    end

    file = File.open(image_params[:name])
    image = ActionDispatch::Http::UploadedFile.new(filename: image_params[:name], type: "image/jpeg", tempfile: file)
    image
  end

  def delete_tmp_file
    File.delete(image_params[:name])
  end
end
