class UsersController < ApplicationController
    def index
        users = User.all
        render json: UsersSerializer.new(users)
    end
end
