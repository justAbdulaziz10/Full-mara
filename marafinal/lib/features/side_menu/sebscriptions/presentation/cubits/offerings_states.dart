import 'package:purchases_flutter/purchases_flutter.dart';

abstract class OfferingsState {}

class OfferingsInitial extends OfferingsState {}

class OfferingsLoading extends OfferingsState {}

class OfferingsLoaded extends OfferingsState {
  final List<Package?> packages;

  OfferingsLoaded(this.packages);
}

class OfferingsError extends OfferingsState {
  final String message;

  OfferingsError(this.message);
}

class PurchaseInProgress extends OfferingsState {}

class PurchaseSuccess extends OfferingsState {
  final String message;

  PurchaseSuccess(this.message);
}