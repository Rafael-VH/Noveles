enum AuthEvent {
  signedIn,
  signedOut,
  tokenRefreshed,
  userChanged,
  /// The auth state stream failed. Not a sign-out: the session may still be
  /// valid, so listeners should re-check instead of logging the user out.
  authError,
}
