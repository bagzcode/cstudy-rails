Rails.application.routes.draw do
  get 'map/jakarta' => 'map#jakarta'
  get 'map/java' => 'map#java'

  root 'map#index'
end
