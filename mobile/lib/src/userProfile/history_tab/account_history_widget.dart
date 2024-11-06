import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/generated/api.swagger.dart' as swagger;
import 'package:mobile/src/auth/auth_controller.dart';
import 'package:mobile/src/userProfile/history_tab/account_history_service.dart';

class AccountHistoryWidget extends StatefulWidget {
  const AccountHistoryWidget({super.key});
  @override
  State<AccountHistoryWidget> createState() => _AccountHistoryWidgetState();
}

class _AccountHistoryWidgetState extends State<AccountHistoryWidget> {
  late Future<List<swagger.AccountHistory>> accountHistoryFuture;
  @override
  void initState() {
    super.initState();
    final username = GetIt.I.get<AuthController>().getUsername();
    accountHistoryFuture =
        GetIt.I.get<AccountHistoryService>().fetchAccountHistory(username);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<swagger.AccountHistory>>(
      future: accountHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.errorFetchingData));
        } else {
          final accountHistory = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.connexionHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: accountHistory.length,
                  itemBuilder: (context, index) {
                    final history = accountHistory[index];
                    final timestamp = history.timestamp.toInt();
                    final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final formattedTimestamp =
                        DateFormat('yyyy-MM-dd – h:mm a').format(dateTime);

                    return ListTile(
                      title: Text(getHistoryActionString(history.action)),
                      subtitle: Text(formattedTimestamp),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  String getHistoryActionString(String action) {
    switch (action) {
      case 'LOGIN':
        return AppLocalizations.of(context)!.loggedIn;
      case 'LOGOUT':
        return AppLocalizations.of(context)!.loggedOut;
      default:
        return action;
    }
  }
}
