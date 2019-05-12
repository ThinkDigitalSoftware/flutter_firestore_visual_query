import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QueryState {
  final List<DocumentSnapshot> results;

  QueryState({@required this.results});
}

class InitialQueryState extends QueryState {
  InitialQueryState() : super(results: []);
}

class QueryResult extends QueryState {
  QueryResult({@required results}) : super(results: results);
}
