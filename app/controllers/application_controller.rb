class ApplicationController < ActionController::API
  def encode_token(payload)
    exp = Time.now.to_i + 12 * 3600
    JWT.encode(payload.merge(exp:), 'anchalsecretkey')
  end

  def decode_token
    header = request.headers['Authorization']
    return unless header

    token = header.split(' ')[1]
    return nil if BlacklistToken.find_by(token:).present?

    begin
      decoded_token = JWT.decode(token, 'anchalsecretkey')
      user_id = decoded_token[0]['user_id']
      User.find_by(id: user_id)
    rescue JWT::ExpiredSignature
      nil
    rescue JWT::DecodeError
      nil
    end
  end

  def user_auth
    @current_user = decode_token if @current_user.nil?
    return render json: { message: 'please log in' }, status: :unauthorized if @current_user.nil?

    if @current_user.deleted?
      if @current_user.deleted_at >= 30.days.ago
        render json: { message: 'Your account was deleted recently. Please restore' },
               status: :unauthorized
      else
        render json: { message: 'Your account has been deleted and cannot be accessed' }, status: :unauthorized
      end
      return
    end

    @current_user
  end
end
