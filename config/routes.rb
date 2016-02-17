Rails.application.routes.draw do
  get 'collector_yards/index'

  get 'map/jakarta' => 'map#jakarta'
  get 'map/java' => 'map#java'
  get 'map/sub_district_jabodetabek' => 'map#sub_district_jabodetabek'

  get 'map/movement_in' => 'map#movement_in'
  get 'map/movement_out' => 'map#movement_out'
  get 'map/collector_yards' => 'map#collector_yards'

  get 'results' => 'movements#results'

  resources :movements

  root 'map#index'
end
