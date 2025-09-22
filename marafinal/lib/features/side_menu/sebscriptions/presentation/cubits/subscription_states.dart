abstract class SubscriptionStates {}

class SubscriptionInitial extends SubscriptionStates {}

class SubscriptionLoading extends SubscriptionStates {}

class SubscriptionLoaded extends SubscriptionStates {
  final bool isSubscribed;

  SubscriptionLoaded(this.isSubscribed);
}

class SubscriptionError extends SubscriptionStates {
  final String message;

  SubscriptionError(this.message);
}