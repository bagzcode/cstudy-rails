Rails.application.routes.draw do
  get 'collector_yards/index'

  get 'movements/index'

  get 'map/jakarta' => 'map#jakarta'
  get 'map/java' => 'map#java'

  get 'map/movement_in' => 'map#movement_in'
  get 'map/movement_out' => 'map#movement_out'
  get 'map/collector_yards' => 'map#collector_yards'

  resources :movements

  root 'map#index'
end
