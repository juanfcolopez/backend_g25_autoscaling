module Api
  module V1
    class MessagesController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :set_chat
      before_action :check_if_open, only: [:create]
      before_action :authenticate_and_load_user
      before_action :authenticate_member, only: [:create]

      # POST api/v1/chats/[chat_id]/messages
      def create
        @message = @chat.messages.new(message_params)
        @message.user = @current_user
        @message.save
        message_copy = @message.attributes
        message_copy[:username] = @current_user.username
        render json: {
          messages: "Request Successfull!",
          is_success: true,
          data: { message: message_copy }
        }
      end

      private
      
      def authenticate_member
        permission = Member.where(chat_id: @chat.id, user_id: @current_user.id)
        if !@chat[:private]
            return true
        elsif permission.length == 0
            render json: {
                messages: "You dont have the permissions to create a message in the chat",
                is_success: false,
                data: {}
            }
        elsif permission[0].valid_flag
            return true
        elsif @chat.user == @current_user
            return true
        else
            render json: {
                messages: "You dont have the permissions to create a message in the chat",
                is_success: false,
                data: {}
            }
        end
      end    

      def message_params
        params.require(:message).permit(:body, :chat_id)
      end

      def set_chat
        @chat = Chat.find(params[:chat_id])
      end

      def check_if_open
        return if !@chat.closed
        render json: {
          messages: "Chat is closed",
          is_success: false,
          data: {}
        }, status: :bad_request
      end

      def authenticate_and_load_user
        authentication_token = nil
        if request.headers["Authorization"]
            authentication_token = request.headers["Authorization"].split[1]
        end
        if authentication_token
            user = JWT.decode(authentication_token, nil, false, algorithms: 'RS256')
            username = user[0]["nickname"]
            email = user[0]["name"]

            if user[0]['sub'].include? 'google-oauth2'
              email = username + '@gmail.com'
            end
            
            @current_user = User.find_by(email: email, username: username)
            if !@current_user.present?
                user = User.new(email: email, username: username, password: '000000', password_confirmation: '000000', auth_token: authentication_token)
                if user.save
                    @current_user = user
                end
            end
        end
        return if @current_user.present?
        render json: {
            messages: "Can't authenticate user",
            is_success: false,
            data: {}
            }, status: :bad_request
      end

    end
  end
end