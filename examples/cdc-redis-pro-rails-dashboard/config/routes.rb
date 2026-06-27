Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"

  get "streams" => "modes#streams"
  post "streams/run" => "modes#run_streams", as: :run_streams

  get "pubsub" => "modes#pubsub"
  post "pubsub/run" => "modes#run_pubsub", as: :run_pubsub

  get "sharded-pubsub" => "modes#sharded_pubsub"
  post "sharded-pubsub/run" => "modes#run_sharded_pubsub", as: :run_sharded_pubsub

  get "keyspace" => "modes#keyspace"
  post "keyspace/run" => "modes#run_keyspace", as: :run_keyspace

  get "orchestrator" => "modes#orchestrator"
  post "orchestrator/run" => "modes#run_orchestrator", as: :run_orchestrator

  get "docs" => "docs#index"
  post "docs/api/generate" => "docs#generate", as: :generate_api_docs
  get "license" => "license#index"

  resources :demo_runs, only: :show
end
