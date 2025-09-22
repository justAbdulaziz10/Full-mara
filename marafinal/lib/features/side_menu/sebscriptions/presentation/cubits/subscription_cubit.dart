import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_states.dart';
import 'package:marafinal/features/side_menu/sebscriptions/data/revenuecat_service.dart';

class SubscriptionCubit extends Cubit<SubscriptionStates> {
  SubscriptionCubit() : super(SubscriptionInitial());

  Future<void> checkProStatus() async {
    emit(SubscriptionLoading());
    try {
      final bool isSubscribed = await RevenueCatService.isUserSubscribed();
      print("Subscription status in Cubit: $isSubscribed");
      emit(SubscriptionLoaded(isSubscribed));
    } catch (e) {
      print("Error in SubscriptionCubit: $e");
      emit(SubscriptionError("Failed to check subscription status"));
    }

  }
}