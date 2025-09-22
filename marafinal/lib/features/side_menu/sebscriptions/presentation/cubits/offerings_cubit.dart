import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/side_menu/sebscriptions/data/revenuecat_service.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/offerings_states.dart';

class OfferingsCubit extends Cubit<OfferingsState> {
  OfferingsCubit() : super(OfferingsInitial());

  List<Package> _packages = [];

  Future<void> loadOfferings() async {
    emit(OfferingsLoading());
    try {
      Offerings? offerings = await RevenueCatService.fetchOfferings();
      if (offerings != null && offerings.current != null) {
        _packages = [];

        if (offerings.current!.monthly != null) {
          _packages.add(offerings.current!.monthly!);
        }
        if (offerings.current!.annual != null) {
          _packages.add(offerings.current!.annual!);
        }

        emit(OfferingsLoaded(_packages));
      } else {
        emit(OfferingsError("No offerings available"));
      }
    } catch (e) {
      print("Error loading offerings: $e");
      emit(OfferingsError(e.toString()));
    }
  }

  Future<void> purchasePackage(Package package, Function onSuccess) async {
    emit(OfferingsLoading());
    try {
      CustomerInfo? customerInfo = await RevenueCatService.purchasePackage(
        package,
      );
      if (customerInfo != null &&
          customerInfo.entitlements.active.containsKey("premium")) {
        onSuccess();
      } else {
        emit(OfferingsLoaded(_packages));
      }
    } on PlatformException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError.name) {
        emit(OfferingsLoaded(_packages));
      } else {
        print("Error purchasing package: $e");
        emit(OfferingsError(e.toString()));
      }
    } catch (e) {
      print("Error purchasing package: $e");
      emit(OfferingsError(e.toString()));
    }
  }
}
