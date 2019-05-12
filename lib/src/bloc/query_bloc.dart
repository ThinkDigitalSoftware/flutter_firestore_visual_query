import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firestore_visual_query/src/bloc/bloc.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final Firestore firestore;

  QueryBloc({@required this.firestore});

  @override
  QueryState get initialState => InitialQueryState();

  @override
  Stream<QueryState> mapEventToState(
    QueryEvent event,
  ) async* {
    if (event is NewQueryEvent) {
      var querySnapshot = await firestore
          .collection(event.collection)
          .where(event.field,
              isEqualTo: event.isEqualTo,
              isLessThan: event.isLessThan,
              isLessThanOrEqualTo: event.isLessThanOrEqualTo,
              isGreaterThan: event.isGreaterThan,
              isGreaterThanOrEqualTo: event.isGreaterThanOrEqualTo,
              arrayContains: event.arrayContains,
              isNull: event.isNull)
          .getDocuments();
      List<DocumentSnapshot> documents = querySnapshot.documents;

      yield QueryResult(results: documents);
    }
    yield this.currentState;
  }
}

class LoggingDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrintSynchronously("Event: ${transition.event}\n"
        "${transition.nextState}");
  }
}
