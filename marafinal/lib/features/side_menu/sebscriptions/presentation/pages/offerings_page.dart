import 'package:flutter/material.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/offerings_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/offerings_states.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_states.dart';

class OfferingsPage extends StatelessWidget {
  const OfferingsPage({super.key});

  final String privacyPolicyUrl = 'https://iammara.com/policy';
  final String euaUrl = 'https://iammara.com/policy';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _handlePurchase(BuildContext context, Package package) {
    final offeringsCubit = context.read<OfferingsCubit>();
    final subcriptionCubit = context.read<SubscriptionCubit>();

    offeringsCubit.purchasePackage(package, () {
      subcriptionCubit.checkProStatus();

      subcriptionCubit.stream
          .firstWhere(
            (subState) =>
                subState is SubscriptionLoaded && subState.isSubscribed,
          )
          .then((value) => Navigator.pop(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final offeringsCubit = context.read<OfferingsCubit>();

    offeringsCubit.loadOfferings();

    final ColorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Offerings")),
      body: BlocBuilder<OfferingsCubit, OfferingsState>(
        builder: (context, state) {
          if (state is OfferingsLoading || state is OfferingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OfferingsError || state is PurchasesError) {
            final errorMsg = state is OfferingsError
                ? state.message
                : (state as PurchasesError).message;
            return Center(child: Text("Error: $errorMsg"));
          }

          if (state is OfferingsLoaded) {
            final packages = state.packages;

            if (packages.isEmpty) {
              return const Center(child: Text("No offerings available."));
            }

            return ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];

                final subDuration = package!.identifier.contains("Annual")
                    ? "year"
                    : "month";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          package.storeProduct.title,
                          style: TextStyle(
                            color: ColorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        Text(
                          package.storeProduct.priceString +
                              " / " +
                              subDuration,
                        ),

                        MaterialButton(
                          onPressed: () {
                            _handlePurchase(context, package);
                          },
                          color: Colors.green,
                          child: Text(
                            "Subscribe now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
