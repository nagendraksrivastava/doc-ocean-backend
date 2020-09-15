class StatusCode
  APP_VERSION_DEPRECIATED                         = 101

  SUCCESS                                         = 200
  INCORRECT_AUTHENTICATION                        = 401
  UNPROCESSABLE_ENTITY                            = 422
  NO_RECORD_FOUND                                 = 404
  BAD_REQUEST                                     = 400

  #User Status Code
  USER_FAILED_TO_CREATE                           = 250
  LOGIN_NO_USER_FOUND                             = 251
  LOGIN_INVALID_EMAIL_OR_PASSWORD                 = 252
  LOGOUT_FAILED                                   = 253
  USER_IS_NOT_EXPERT                              = 261
  INVALID_USER_ADDRESS                            = 262

  #Patient Status Code
  PATIENT_CREATION_FAILED                         = 551
  PATIENT_DETAILS_REQUIRED                        = 552

  #Expert Status Code
  NO_EXPERTS_AVAILABLE                            = 901
  NO_EXPERTS_AVAILABLE_FOR_SCHEDULE_TIME          = 902

  APPOINTMENT_STATUS_UPDATE_FAILED                = 601
  APPOINTMENT_RATING_FAILED                       = 602
  APPOINTMENT_SCHEDULE_TIME_PAST                  = 603
  APPOINTMENT_PATIENT_ADDRESS_BLANK_ERROR         = 604
  APPOINTMENT_INVALID_PATIENT_ADDRESS             = 605

  USER_DEVICE_CHECKSUM_FAILED                     = 701

  INVALID_NOTIFICATION                            = 801
  INVALID_NOTIFICATION_STATUS_TRANSITION          = 802
  NOTIFICATION_FAILED_TO_UPDATE                   = 803

  MESSAGES = {
    101 => 'App version depreciated. Please update your app',
    200 => 'Success',
    250 => 'User failed to create',
    251 => 'User doesn\'t exists',
    252 => 'Invalid email or password',
    253 => 'Logout failed',
    261 => 'User is not expert',
    262 => 'Address does not belong to user',

    401 => 'Incorrect authentication. Please authenticate correctly',
    422 => 'Unprocessable entity',
    404 => 'Record not found',

    #Patient Status Code Messages
    551 => 'Failed to create patient',
    552 => 'Enter valid patient details',
    601 => 'Appointment status update failed',
    602 => 'Appointment rating failed to create',
    603 => 'Schedule time should be 3 hours greater than current time',
    604 => 'Patient address can\'t be blank',
    605 => 'Invalid patient address',

    701 => 'User device checksum failed',
    801 => 'Invalid notification',
    802 => 'Invalid notification status transition',
    803 => 'Notification failed to update',

    901 => 'No experts available',
    902 => 'No experts available for this time'
  }.freeze

  def self.response_message(code, message = nil)
    response            = {}
    response[:code]     = code
    response[:message]  = message.present? ? message : MESSAGES[code]
    response
  end
end
