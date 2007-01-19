class ClientController < ApplicationController
  before_filter :authorize_login

  layout "ref"

end