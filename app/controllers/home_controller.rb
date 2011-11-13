class HomeController < ApplicationController
  layout 'home'
  def index
    @show_main = true
  end
end