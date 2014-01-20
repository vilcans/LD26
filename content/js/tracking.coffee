# Support for Google Analytics event tracking

@Tracking =

  # Report an event.
  #
  # category (required): The name you supply for the group of objects
  # you want to track.
  #
  # action (required): A string that is uniquely paired with each
  # category, and commonly used to define the type of user interaction
  # for the web object.
  #
  # label (optional): An optional string to provide additional
  # dimensions to the event data.
  #
  # value (optional): An integer that you can use to provide numerical
  # data about the user event.
  #
  # non-interaction (optional): A boolean that when set to true,
  # indicates that the event hit will not be used in bounce-rate
  # calculation.
  #
  # See
  # https://developers.google.com/analytics/devguides/collection/analyticsjs/events
  trackEvent: (category, action, {label, value, nonInteraction}={}) ->
    if not window.ga
      return
    ga 'send', 'event', category, action, label, value, {nonInteraction: !!nonInteraction}
