class Api::V1::LocationsController < Api::BaseController

  def cities
    render json: {status: StatusCode.response_message(StatusCode::SUCCESS),
                      cities: City.active.map{|c| {id: c.id, name: c.name}}
    }
  end

  def localities
    params.require(:city_id)
    city = City.find(params[:city_id])
    render json: {status: StatusCode.response_message(StatusCode::SUCCESS),
                      localities: city.active_loaclities
    }
  end
end
