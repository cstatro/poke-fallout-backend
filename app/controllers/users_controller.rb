class UsersController < ApplicationController
    def index
        users = User.all
        render json: UsersSerializer.new(users)
    end
    def create
        user = User.new(user_params)
        user.save
        render json: UsersSerializer.new(user)   
    end

    def kill_rejects

    end

    private 
    def user_params
        params.require(:user).permit(:name)
    end
end
