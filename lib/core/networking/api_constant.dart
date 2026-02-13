class ApiConstant {
  static const String baseUrl = 'https://traduap.com/';
  static const String loginEndPoint = 'api/auth/login';
  static const String registerEndPoint = 'api/auth/register';
  static const String meEndPoint = 'api/auth/me';
  static const String logoutEndPoint = 'api/auth/logout';
  static const String verifyCodeEndPoint = 'api/auth/verifyCode';
  static const String resendVerificationCodeEndPoint =
      'api/auth/resendVerificationCode';
  static const String forgotPasswordOtpEndPoint = 'api/auth/forgot-password';
  static const String verifyForgotPasswordOtpEndPoint =
      'api/auth/verify-reset-code';
  static const String refreshTokenEndPoint = 'api/auth/refresh';
  static const String deleteAccountEndPoint = 'api/auth/delete';
  static const String resetPasswordEndPoint = 'api/auth/reset-password';
  static const String appVersionEndPoint = 'api/app-version';

  static const String plansEndPoint = 'api/plans';
  static const String offersEndPoint = 'api/getoffers';
  static const String notificationsEndPoint = 'api/notifications';
  static const String usersPlanEndPoint = 'api/users-plan';
  static const String subscribePlanEndPoint = 'api/subscribe';
  static const String checkplanEndPoint = 'api/checkplan';
  static const String withdrawEndPoint = 'api/withdraw';
  static const String lastTransactionsEndPoint = 'api/last-transactions';
  static const String planResultEndPoint = 'api/plan-result';

  static const String deviceTokenEndPoint = 'api/token';
  static const String agentEndPoint = 'api/agent';
  static const String getAllChats = 'api/getuserchats';
  static const String sendMessage = 'api/chat/send';
  static const String sendMessageAsAdmin = 'api/chat/sendadmin';
  static const String getChatMessages = 'api/chat';
  static const String markAsRead = 'api/changemassegereadstaus';

  static const String sendNotificationEndPoint =
      "/api/send-notification"; // adjust path as needed
  static const String redeemGiftEndPoint = 'api/gift/redeem';
  static const String getGiftEndPoint = 'api/gift';
  static const String postsEndPoint = 'api/posts';
  static const String changeUserChatStatus = 'api/changeuserchatstatus';
  static const String userWalletEndPoint = 'api/user-wallet';
  static const String usdToCryptoEndPoint = 'api/usd_to_crypto';
  static const String cryptoToUsdEndPoint = 'api/crypto_to_usd';
  static const String cryptoToCryptoEndPoint = 'api/crypto_to_crypto';
}
