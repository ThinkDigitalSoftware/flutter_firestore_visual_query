import 'package:meta/meta.dart';

@immutable
abstract class QueryEvent {}

class NewQueryEvent extends QueryEvent {
  final String collection;
  final String field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final bool isNull;

  NewQueryEvent({
    this.collection,
    this.field,
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.isNull,
  }) {
    assert(
        [
              this.isEqualTo,
              this.isLessThan,
              this.isLessThanOrEqualTo,
              this.isGreaterThan,
              this.isGreaterThanOrEqualTo,
              this.arrayContains,
              this.isNull
            ].where((element) => element != null).length ==
            1,
        "only one of these can be selected for any given query."
        "isEqualTo: $isEqualTo,"
        "isLessThan: $isLessThan,"
        "isLessThanOrEqualTo: $isLessThanOrEqualTo,"
        "isGreaterThan: $isGreaterThan,"
        "isGreaterThanOrEqualTo: $isGreaterThanOrEqualTo,"
        "arrayContains: $arrayContains,"
        "isNull: $isNull");
  }
}
