class UsersController < ApplicationController
    def index
        users = User.all
        render json: UsersSerializer.new(users)
    end

    def show
        user = User.find_by(name: params[:name].downcase)
        render json: UsersSerializer.new(user)
    end

    def create
        user = User.new(user_params)
        user.update(name: name.downcase)
        user.save
        render json: UsersSerializer.new(user)   
    end
    private 
    def user_params
        params.require(:user).permit(:name)
    end
end
