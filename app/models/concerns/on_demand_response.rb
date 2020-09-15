class OnDemandResponse
  def initialize(expert_detail, availability, options = {})
    @expert_detail = expert_detail
    @user = expert_detail.user
    @availability = availability
    @options = options
  end

  def response
    address = @availability.address
    {
      name: @user.name,
      email: @user.email,
      phone_no: @user.phone_no,
      gender: @user.gender,
      image_url: @user.image_url(:thumb),
      expert_detail_id: @expert_detail.id,
      profession_id: @expert_detail.profession_id,
      profession_code: @expert_detail.profession.code,
      profession: @expert_detail.profession.name,
      degree_list: @expert_detail.degree_list,
      specialization_list: @expert_detail.specialization_list,
      license_no: @expert_detail.license_no,
      consulting_fee: @expert_detail.consulting_fee.to_f,
      rating: @user.average_rating,
      service_place: @expert_detail.service_place,
      address: {
        id: address.id,
        address_line: address.address_line,
        locality: address.locality.try(:name),
        locality_id: address.locality_id,
        city: address.city.try(:name),
        city_id: address.city_id,
        landmark: address.landmark,
        latitude: address.latitude.to_f,
        longitude: address.longitude.to_f,
        phone_no: address.phone_no,
        tag: address.tag,
        timing: {
          start_time: @availability.start_time.strftime('%H:%M'),
          end_time: @availability.end_time.strftime('%H:%M')
        }
      }
    }
  end
end
