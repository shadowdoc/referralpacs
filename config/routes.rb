Ref::Application.routes.draw do
  resources :locations
  match '' => 'login#login'
  match 'encounter/status/:requested_status' => 'encounter#status'
  match '/:controller(/:action(/:id))'
end
